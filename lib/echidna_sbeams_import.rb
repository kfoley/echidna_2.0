module EchidnaImport

  class DirNotFound < Exception
  end

  # This 'importer' simply extracts condition names from the
  # experiment directory.
  # To do this, it simply returns all .sig entries in
  # the specified directory. If the directory does not
  # exist, an EchidnaImport::DirNotFound exception is raised
  class SbeamsImporter

    def initialize(arrays_dir, project_id, timestamp)
      @arrays_dir  = arrays_dir
      @project_id  = project_id
      @timestamp   = timestamp
    end

    def conditions
      if File.directory?(experiment_dir)
        result = []
        Dir.new(experiment_dir).each {|file|
          result << file if file.end_with?('.sig')
        }
        result
      else
        raise DirNotFound.new
      end
    end

  private
    def experiment_dir
      "#{@arrays_dir}/Pipeline/output/project_id/#{@project_id}/#{@timestamp}"
    end
  end
end

