# This module includes import functionality for Echidna
# requires gem 'activerecord-import' for 3.x or 'ar-extensions' for 2.x
module EchidnaImport

  # Creates a map object that reads the latest oligo map file
  # and creates mappings from REF => SEQUENCE_NAME
  class OligoMapFactory
    OLIGO_MAP_IDX_REF = 4
    OLIGO_MAP_IDX_VNG = 10

    def initialize(arrays_dir)
      @arrays_dir = arrays_dir
    end

    def make_oligo_map
      latest = latest_oligo_map_file
      puts "Latest oligo map: '#{latest}'"
      result = {}
      File.open(latest) do |infile|
        infile.each_line do |line|
          if infile.lineno > 1 then
            comps = line.split("\t")
            result[comps[OLIGO_MAP_IDX_REF]] = comps[OLIGO_MAP_IDX_VNG]
          end
        end
      end
      result
    end

  private

    def oligo_filenames
      `ls -1 #{@arrays_dir}/Slide_Templates/halo_oligo*.map`.split("\n")
    end

    def latest_oligo_map_file
      tmp_files = []
      oligo_filenames.each do |filename|
        # split the identifier into 2 parts to accurately sort by number
        number = filename.gsub(/.*halo_oligo_/, "").gsub(/\.map/, "").split('-')
        tmp_files <<= [number[0].to_i, number[1].to_i, filename]
      end
      sorted = tmp_files.sort do |a, b|
        a[0] + a[1] <=> b[0] + b[1]
      end
      sorted.last[2]
    end

  end

  # Read and hold data stored in a matrix_output file into
  # this class for convenient retrieval.
  class DataMatrix
    attr_reader :headers, :data

    def initialize(filename)
      read_matrix_output(filename)
    end
  
    # extract the unique conditions from the matrix header line
    def conditions
      @headers.slice(2, (@headers.length - 3) / 2)
    end

  private

    def read_matrix_output(filename)
      @headers = []
      @data = []
      File.open(filename) do |file|
        file.each_line do |line|
          line = line.strip
          if file.lineno == 2 then
            @headers = line.split("\t")
          end
          # ignore empty lines, the head line and the NumSigGenes line
          if file.lineno > 2 and not line.empty? and line.match(/^NumSigGenes/).nil? then
            @data << line.split("\t")
            #puts "#{line}"
          end
        end
      end
    end

  end

  # when in rails, add the requirement to the gemfile
  class ExperimentImporter

    FEATURE_DATATYPE_RATIO  = 1
    FEATURE_DATATYPE_LAMBDA = 2

    def initialize(arrays_dir, project_id, timestamp, importer_id = 0)
      @arrays_dir  = arrays_dir
      @project_id  = project_id
      @timestamp   = timestamp
      @importer_id = importer_id
    end

    def experiment_dir
      "#{@arrays_dir}/Pipeline/output/project_id/#{@project_id}/#{@timestamp}"
    end

    def import
      data_matrix = DataMatrix.new("#{experiment_dir}/matrix_output")
      group = nil
      Condition.transaction do
        group = ConditionGroup.new(:name => "Conditions Imported #{Time.now} (V2)",
                                   :owner_id => @importer_id)
        group.save
        conditions = create_conditions(group, data_matrix)
        add_features(group, conditions, data_matrix)

        # debugging: roll everything back
        puts "done, rolling back now..."
        raise ActiveRecord::Rollback
      end
      group
    end

  private

    # activerecord_import is superfast when importing raw arrays. We'll use those then
    def create_feature(value, condition, datatype, gene_id)
      [value, condition.id, gene_id, datatype]
    end
  
    def add_features_for_row(features, datarow, data_size, gene_id, conditions)
      ratios  = datarow.slice(2, data_size)
      lambdas = datarow.slice(2 + data_size, data_size)
      ratios.each_with_index do |ratio, index|
        features << create_feature(ratio, conditions[index],
                                   FEATURE_DATATYPE_RATIO, gene_id)
      end
      lambdas.each_with_index do |lambda, index|
        features << create_feature(lambda, conditions[index],
                                   FEATURE_DATATYPE_LAMBDA, gene_id)
      end
    end

    def add_features(group, conditions, data_matrix)
      oligo_map = OligoMapFactory.new(@arrays_dir).make_oligo_map
      genes = Gene.find :all

      features = []
      data_matrix.data.each do |datarow|
        vng_name = oligo_map[datarow[0]]
        gene_id  = Gene.find_by_name(vng_name).id
        data_size = (datarow.length - 3) / 2
        add_features_for_row(features, datarow, data_size, gene_id, conditions)
      end
      puts "importing #{features.length} features...."
      # submit features to activerecord-import as raw arrays for speed
      columns = [:value, :condition_id, :gene_id, :data_type]
      Feature.import columns, features, :validate => false
    end

    def create_conditions(group, data_matrix)
      slidenums = slide_map
      conds = data_matrix.conditions
      result = []
      conds.each_with_index do |cond, index|
        key = cond.gsub(/\.sig/, "")
        c = Condition.new(:name => cond,
                          :sequence => index + 1,
                          :forward_slide_number => slidenums[key][:forward],
                          :reverse_slide_number => slidenums[key][:reverse])
        c.save
        result << c
        cgroup = ConditionGrouping.new(:condition_group_id => group.id,
                                       :condition_id => c.id,
                                       :sequence => index + 1)
        cgroup.save
      end
      result
    end

    def ft_filenames
      `ls -1 #{experiment_dir}/*.ft`.split("\n")
    end
  
    # extract the forward/reverse slide numbers from the ft files
    # and create a map from sig file number => [forward slide, reverse slide]
    # difference to PipelineImporter:
    # - key is the base name, not sig name
    # - value is a hash map with keys :forward and :reverse
    def slide_map
      result = {}
      ft_filenames.each do |ft_filename|
        name = ft_filename.split("/").last().gsub(/\.ft$/,"")
        result[name] = { :forward => nil, :reverse => nil }
        File.open(ft_filename) do |ft_file|
          ft_file.each_line do |line|
            comps = line.split("\t")
            slidenum = comps[0].split('.')[0]
            if (comps[1] == 'f') then
              result[name][:forward] = slidenum
            elsif (comps[1] == 'r') then
              result[name][:reverse] = slidenum
            end
          end
        end
      end
      result
    end
  end

end
