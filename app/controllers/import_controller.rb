class ImportController < ApplicationController
  def experiment
    # arrays_dir, project_id, timestamp, importer_id = 0
    @project_id     = params[:project_id]
    @timestamp      = params[:timestamp]
    @import_user_id = 0
    @vocab_items    = get_vocabulary_for_select
    @units          = get_units_for_select

    if !@project_id.nil? and !@timestamp.nil? then
#=begin
      importer = EchidnaImport::ExperimentImporter.new(ECHIDNA_CONFIG['arrays_dir'],
                                                       @project_id,
                                                       @timestamp,
                                                       @import_user_id)
      @group = importer.import
#=end
      puts "import done - rolled back"
      # @group = ConditionGroup.find(318)
      @group.conditions.each do | cond |
        cond.observations.build
      end
    else
      # @group = nil
    end
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
