require 'echidna_sbeams_import'

class ImportWizardController < ApplicationController
  def index
  end

  def conditions_ajax
    importer = EchidnaImport::SbeamsImporter.new(ECHIDNA_CONFIG['arrays_dir'],
                                                 params[:project_id],
                                                 params[:timestamp])
    render :json => importer.conditions
  end

  # render conditions and groups as an HTML table with id 'condition-list'
  def conditions_and_groups
    importer = EchidnaImport::SbeamsImporter.new(ECHIDNA_CONFIG['arrays_dir'],
                                                 params[:project_id],
                                                 params[:timestamp])
    @conditions = importer.conditions
    #render :layout => false
    render :json => @conditions
  end
end
