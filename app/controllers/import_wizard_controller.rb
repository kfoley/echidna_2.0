require 'echidna_sbeams_import'

class ImportWizardController < ApplicationController
  def index
  end

  # render conditions and groups as an HTML table with id 'condition-list'
  def conditions_and_groups
    importer = EchidnaImport::SbeamsImporter.new(ECHIDNA_CONFIG['arrays_dir'],
                                                 params[:project_id],
                                                 params[:timestamp])
    condition_and_groups = {}
    conditions = importer.conditions
    conditions.each do |cond|
      condition_and_groups[cond] = []
    end
    render :json => condition_and_groups
  end
end
