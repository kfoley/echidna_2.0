require 'vendor/plugins/blacklight/app/helpers/catalog_helper.rb'

module CatalogHelper

 # Export to Refworks URL, called in _show_tools                                                                                                   
  def csv_export(document = @document)                                                                                                     
    # "http://www.refworks.com/express/expressimport.asp?vendor=#{CGI.escape(application_name)}&filter=MARC%20Format&encoding=65001&url=#{CGI.escape(catalog_path(document[:id], :format => 'refworks_marc_txt', :only_path => false))}"
    print document[:id]
  end    

end