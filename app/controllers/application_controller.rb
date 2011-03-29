require_dependency( 'vendor/plugins/blacklight/app/controllers/application_controller.rb')
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :my_assets

  def get_json_for_datatables args
    #group_props ||= args[:document].get("group_property", :sep => nil) if args[:document] and args[:field]
    #condition_ids ||= args[:document].get("condition_id", :sep => nil) if args[:document] and args[:field]
    #data_type ||= args[:document].get("measurement_type", :sep => nil) if args[:document] and args[:field]
    #conditions ||= args[:document].get("condition_name", :sep => nil) if args[:document] and args[:field]
    #keys ||= args[:document].get("property_key", :sep => nil) if args[:document] and args[:field]
    #vals ||= args[:document].get("property_value", :sep => nil) if args[:document] and args[:field]

    group_props = args[:document].get("group_property", :sep => nil) #if args[:document] and args[:field]
    condition_ids = args[:document].get("condition_id", :sep => nil) #if args[:document] and args[:field]
    data_type = args[:document].get("measurement_type", :sep => nil) #if args[:document] and args[:field]
    conditions = args[:document].get("condition_name", :sep => nil) #if args[:document] and args[:field]
    keys = args[:document].get("property_key", :sep => nil) #if args[:document] and args[:field]
    vals = args[:document].get("property_value", :sep => nil) #if args[:document] and args[:field]

    testArray = condition_ids.zip(keys,vals)

    output = {}
    testArray.each do |outer_key, inner_key, value|
      output[outer_key] ||= {}
      output[outer_key][inner_key] ||= []
      output[outer_key][inner_key] << value
    end

    aaData = []
    c_ids = []
    c_ids = output.keys
    sEcho = 0
    iTotalRecords = c_ids.length
    iTotalDisplayRecords = c_ids.length
   
    c_ids.each_with_index do |id, index_i|

      h_conds = output[id]
      aaData[index_i] = []
      aaData[index_i][0] = id
      group_props.each_with_index do |gp, index_j|
        v = h_conds[gp]
        if v != ""
          aaData[index_i][index_j + 1] = v
        else
          aaData[index_i][index_j + 1] = ""
        end          
      end
    end

    aaData = [ "sEcho" => 0,
               "iTotalRecords" => iTotalRecords,
               "iTotalDisplayRecords" => iTotalDisplayRecords,
               "aaData" => aaData
             ]
    puts aaData.to_json
    render :json => aaData
=begin
    array_group = testArray.group_by { |row| row[0] }
    prop_keys = []
    prop_vals = []
    array_group.each_pair do |key,value|
      second_values = []
      third_values = []
      value.each do |pair|
        second_values << pair[1]
        third_values << pair[2]
      end
      prop_keys << second_values
      prop_vals << third_values
    end

    prop_keys.each do |elem|
      elem.each_with_index do |item,index|
        #puts item
        #puts group_props[index]
      end
      #puts "#{elem.join(', ')}"
    end

    condition_ids.each_with_index { |x,y| 

      group_props.each_with_index { |a,b| 
        if group_props[b] == keys[y]
          #puts group_props[counter]
          #puts keys[y]
          aaRow << vals[y].to_s
        #else
         # aaRow << " "
        end
      }
      if condition_ids[y] != condition_ids[y+1]
        counter = 0
      else
        counter += 1
      end

    }

    #aaData << aaRow
    #counter += 1
=end
  end


  protected
  def my_assets
    stylesheet_links << "echidna"
    stylesheet_links << "echidna-wizard"
    stylesheet_links << "DataTables-1.7.6/media/css/demo_table_jui.css"
    stylesheet_links << "DataTables-1.7.6/media/css/demo_page.css"
    stylesheet_links << "DataTables-1.7.6/media/css/demo_table.css"
    javascript_includes << "DataTables-1.7.6/media/js/jquery.dataTables.min.js"
    javascript_includes << "catalogDataTables.js"
  end


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
