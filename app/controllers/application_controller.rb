require_dependency( 'vendor/plugins/blacklight/app/controllers/application_controller.rb')
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :my_assets

  def condition_names 
    c_id = params[:id]
    c_name = Composite.find_by_id(c_id)
    result = Hash.new
    result["name"] = c_name.name
    render :json => result
  end

  protected
  def my_assets
    stylesheet_links << "DataTables-1.7.6/media/css/demo_table_jui.css"
    stylesheet_links << "DataTables-1.7.6/media/css/demo_page.css"
    stylesheet_links << "DataTables-1.7.6/media/css/demo_table.css"
    stylesheet_links << "echidna"
    stylesheet_links << "echidna-wizard"
    stylesheet_links << "smoothness/jquery-ui-1.8.9.custom.css"
    stylesheet_links << "jquery.qtip.min.css"
    javascript_includes << "DataTables-1.7.6/media/js/jquery.dataTables.min.js"
    javascript_includes << "collapsing_divs.js"
    javascript_includes << "catalogDataTables.js"
    javascript_includes << "jquery-ui-1.8.9.custom.min.js"
    javascript_includes << "jquery.qtip2/jquery.qtip.min.js"
  end


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
