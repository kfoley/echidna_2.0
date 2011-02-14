class ImportController < ApplicationController
  def experiment
    # arrays_dir, project_id, timestamp, importer_id = 0
    @project_id     = params[:project_id]
    @timestamp      = params[:timestamp]
    @import_user_id = 0
    @vocab_items    = get_vocabulary_for_select
    @units          = get_units_for_select
    @names          = get_condition_names

    if !@project_id.nil? and !@timestamp.nil? then
      #importer = EchidnaImport::ExperimentImporter.new(ECHIDNA_CONFIG['arrays_dir'],
      #                                                 @project_id,
      #                                                 @timestamp,
      #                                                 @import_user_id)
      # @group = importer.import
      @group = ConditionGroup.find(318)
      @group.conditions.each do | cond |
        cond.observations.build
      end
    else
      # @group = nil
    end
  end

  def get_condition_names
    @arrays_dir = ECHIDNA_CONFIG['arrays_dir']
    exp_dir = "#{@arrays_dir}/Pipeline/output/project_id/#{@project_id}/#{@timestamp}"
    puts "karen test "
    puts exp_dir
    d_matrix = EchidnaImport::DataMatrix.new("#{exp_dir}/matrix_output")
    conds = d_matrix.conditions
    result = []
    conds.each_with_index do |cond, index|
      #puts cond
      result << [index, cond]
    end
    puts "end karen test"    
    result
  end

  def update
    id = params[:condition_group][:id]
    @group = ConditionGroup.find(id)
    @group.update_attributes(params[:condition_group]);
  end

  private
  
  def get_vocabulary_for_select
    result = []
    items = ControlledVocabItem.all(:order => 'name')
    items.each do |item|
      result << [item.name, item.id]
    end
    result
  end
  def get_units_for_select
    result = []
    units = Unit.all(:conditions => 'name is not null', :order => 'name')
    units.each do |unit|
      result << [unit.name, unit.id]
    end
    result
  end

end
