class IsbexportController < ApplicationController
  include Blacklight::SolrHelper

  def csv
    @reponse, @documents = get_solr_response_for_field_values("id", params[:id])
    id = params[:id]
    respond_to do |format|
      format.csv
    end
  end
end
