require_dependency( 'vendor/plugins/blacklight/app/controllers/application_controller.rb')
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :my_assets

  protected
  def my_assets
    stylesheet_links << "echidna"
    stylesheet_links << "echidna-wizard"
    #javascript_includes << "my_js"
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
