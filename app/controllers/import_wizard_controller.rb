require 'echidna_sbeams_import'
require 'pathname'

class Metadata
  attr_accessor :condition, :metadata_type, :obspert, :value, :unit
  def initialize
    @condition = ''
    @metadata_type = ''
    @obspert = ''
    @value = ''
    @unit = ''
  end
  
  def to_s
    "Metadata t: #{@metadata_type}, cond: #{@condition} op: #{@obspert} val: #{value} unit: #{unit}"
  end
end

class ImportWizardController < ApplicationController
  def index
  end

  # get the list of directories in the sbeams project_id directory
  def get_sbeams_project_dirs()
    directory_name = "#{ECHIDNA_CONFIG['arrays_dir']}/Pipeline/output/project_id"
    dir_list = Pathname.new(directory_name).children.select { |c| c.directory? }.collect { |p| p.to_s }

    all_names = []
    dir_list.each do |folder_name|
      name = {}
      name = File.basename(folder_name)
      all_names << name
    end
    render :json => all_names.sort 
  end

  # get the list of directories in the sbeams timestamp directory from selected project_id
  def get_sbeams_timestamp_dirs 
    @project_id = params[:project_id]
    directory_name = "#{ECHIDNA_CONFIG['arrays_dir']}/Pipeline/output/project_id/#{@project_id}"
    dir_list = Pathname.new(directory_name).children.select { |c| c.directory? }.collect { |p| p.to_s }
    
    all_names = []
    dir_list.each do |folder_name|
      name = {}
      name = File.basename(folder_name)
      all_names << name
    end
    render :json => all_names.sort     

  end

  # render conditions and groups as an HTML table with id 'condition-list'
  def conditions_and_groups
    importer = EchidnaImport::SbeamsImporter.new(ECHIDNA_CONFIG['arrays_dir'],
                                                 params[:project_id],
                                                 params[:timestamp])
    condition_and_groups = []
    conditions = importer.conditions
    conditions.each do |condition_name|
      condition = {}
      condition['condition'] = condition_name
      condition['groups'] = []
      condition_and_groups << condition
    end
    render :json => condition_and_groups
  end

  def notify_solr_to_update
    update_url = "#{ECHIDNA_CONFIG['solr_url']}/dataimport?command=full-import&clean=false&commit=true"
    Net::HTTP.get(URI.parse(update_url))
  end
  
  def import_data
    import_json = params[:import_data]
    import_data = ActiveSupport::JSON.decode(import_json)
    conditions_groups = import_data['conditionsAndGroups']
    condition_names = get_condition_names(import_data['conditionsAndGroups'])
    cond2group = get_conditions2groups(import_data['conditionsAndGroups'])
    group_names = unique_group_names(condition_names, cond2group)

    mdobjects = make_metadata_objects(import_data['metadata'], condition_names)
    base_uri = "/sbeams/#{import_data['sbeamsProjectId']}/#{import_data['sbeamsTimestamp']}"
    group_map = read_group_map_from_db(group_names)

    Condition.transaction do
      condition_map = import_conditions(condition_names)
      import_global_properties(condition_map, import_data)
      assign_measurement_data(condition_map, base_uri)
      assign_condition_groups(condition_map, group_map, cond2group)
      import_observations_perturbations(mdobjects, condition_map)

      notify_solr_to_update
    end
    render :json => ["Ok"]
  end

private

  # creates conditions in the database and returns a map condition_name => condition
  def import_conditions(condition_names)
    condition_map = {}
    condition_names.each {|cond_name|
      condition = Condition.create(:name => cond_name)
      condition_map[cond_name] = condition
    }
    condition_map
  end

  def import_global_properties(condition_map, import_data)
    species      = Property.new(:key => 'species',      :value => import_data['species'])
    data_type    = Property.new(:key => 'data type',    :value => import_data['dataType'])
    slide_type   = Property.new(:key => 'slide type',   :value => import_data['slideType'])
    platform     = Property.new(:key => 'platform',     :value => import_data['platform'])
    slide_format = Property.new(:key => 'slide format', :value => import_data['slideFormat'])
    condition_map.each {|condition_name, condition|
      CompositesProperties.create(:property => species, :composite => condition)
      CompositesProperties.create(:property => data_type, :composite => condition)
      CompositesProperties.create(:property => slide_type, :composite => condition)
      CompositesProperties.create(:property => platform, :composite => condition)
      CompositesProperties.create(:property => slide_format, :composite => condition)
    }
  end

  # establishes condition <-> condition group relationship
  def assign_condition_groups(condition_map, group_map, cond2group)
    condition_map.each {|condition_name, condition|
      condition_group_names = cond2group[condition_name]
      condition_group_names.each {|group_name|
        group = group_map[group_name]
        condition.condition_groups << group
      }
      condition.save
    }
  end

  def import_observations_perturbations(mdobject, condition_map)
    mdobject.each {|metadata|
      condition = condition_map[metadata.condition]
      value = metadata.value if metadata.value != ''
      unit = metadata.unit if metadata.unit != ''
      is_observation = metadata.obspert == 'observation'
      is_perturbation = metadata.obspert == 'perturbation'

      prop = Property.create(:key   => metadata.metadata_type,
                             :value => metadata.value,
                             :unit  => metadata.unit)
      CompositesProperties.create(:property        => prop,
                                  :composite       => condition,
                                  :is_observation  => is_observation,
                                  :is_perturbation => is_perturbation)
    }
  end

  def assign_measurement_data(condition_map, base_uri)
    condition_map.each {|condition_name, condition|
      meas_data = MeasurementData.create(:uri => "#{base_uri}/#{condition_name}")
      condition.measurement_data = meas_data
      condition.save
    }
  end

  # reads/creates condition_groups from the database and returns a map group_name => group
  def read_group_map_from_db(group_names)
    group_map = {}
    group_names.each {|group_name|
      group = ConditionGroup.find_by_name(group_name)
      if group == nil
        puts "group '#{group_name}' does not exist, creating"
        group = ConditionGroup.create(:name => group_name)
      end
      group_map[group_name] = group
    }
    group_map
  end

  # retrieves the unique group names
  def unique_group_names(condition_names, cond2group)
    group_names = []
    condition_names.each {|cond_name|
      cond_groups = cond2group[cond_name]
      cond_groups.each {|group_name|
        if !group_names.include?(group_name)
          group_names << group_name
        end
      }
    }
    group_names
  end

  # retrieves the condition names
  def get_condition_names(conditions_groups)
    conditions = []
    conditions_groups.each {|condgroup|
      conditions << condgroup['condition']
    }
    conditions
  end

  # retrieves condition => group list map
  def get_conditions2groups(conditions_groups)
    cond2group = {}
    conditions_groups.each {|condgroup|
      cond2group[condgroup['condition']] = condgroup['groups']
    }
    cond2group
  end

  # returns an array of Metadata instances
  def make_metadata_objects(metadata, conditions)
    mdobjects = []
    metadata.each {|entry|
      mdtype = entry['metadataType']
      obspert = entry['obspert']
      entry['conditionValues'].each_with_index {|cond_value, index|
        md = Metadata.new
        md.metadata_type = mdtype
        md.condition     = conditions[index]
        md.obspert       = obspert
        md.value         = cond_value['value']
        md.unit          = cond_value['unit']
        mdobjects << md
      }
    }
    mdobjects
  end

end
