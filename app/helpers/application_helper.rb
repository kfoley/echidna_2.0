require 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
require 'uri'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    def application_name
        'Echidna 2.0 - faceted search'
    end

    def get_index_record(document)
        puts "#{document}"
    end

    def render_csv_texts(documents)
      val = ""
      documents.each do |doc|
        val += doc.export_as_csv + "\n"
      end
      val
    end

    # karen: adding action for getting the data locations for all documents in the "folder"
    def dmv_export(documents)
      uris = []
      documents.each do |doc|
        locations = doc[:data_location]
        locations.each_with_index do |locs, i|
          puts "before ========================="
          puts locs
          locs = CGI::escape(locs)
          puts "after ========================="
          puts locs
          st = "uri"
          uris[i] = Hash.new
          uris[i][st] = locs
          puts "========================"
          puts uris[i][st]
          puts "========================"
          #uris << uris[i]["uri"]
        end
      end
      puts "json................................"
      puts uris.to_json
      uris.to_json
    end

  def render_index_field_value args
    value = args[:value]
    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]

    render_field_value value
  end

  def render_get_field_property args
    value = args[:value]
    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]

    condition_ids ||= args[:document].get("condition_id", :sep => nil) if args[:document] and args[:field]
    data_type ||= args[:document].get("measurement_type", :sep => nil) if args[:document] and args[:field]
    conditions ||= args[:document].get("condition_name", :sep => nil) if args[:document] and args[:field]
    keys ||= args[:document].get("property_key", :sep => nil) if args[:document] and args[:field]
    vals ||= args[:document].get("property_value", :sep => nil) if args[:document] and args[:field]

    html_ret = ''
    index = 0
    #while index < keys.length
    #  html_line = "<tr><td>" + keys[index].to_s + "</td> <td>" + vals[index].to_s + "</td></tr>" 
    #  html_ret << html_line
    #  index += 1
    #end


    counter = 0
    test = 0
    html_line = ''
    condition_ids.each_with_index { |x,y| 
      if (y == 0 || counter > test)
        test = counter
        html_line = "<td valign=\"top\"><table class=\"single-cond\"><tr><td>condition name</td><td>" << conditions[counter].to_s << "</td></tr>" << "<tr><td>condition id</td><td>" << condition_ids[y].to_s << "</td></tr>" 
      elsif (condition_ids[y] == condition_ids[y+1])
        html_line = "<tr><td>" << keys[y].to_s << "</td> <td>" << vals[y].to_s << "</td></tr>" 
      else
        html_line = "<tr><td>" << keys[y].to_s << "</td> <td>" << vals[y].to_s << "</td></tr></table></td>" 
        counter += 1
      end
      html_ret << html_line
    }

    html_ret
  end

  def get_json_headers_datatables args
    group_props = args[:document].get("group_property", :sep => nil) #if args[:document] and args[:field]
    
    html_line = ''
    html_ret = ''
    group_props.each do |prop|
      html_line = "<th>" << prop << "</th>" 
      html_ret << html_line
    end
    html_ret = "<th>Condition Id</th>" << html_ret
    html_ret 
  end

  def get_json_for_datatables args
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
    html_line = ''
    html_ret = ''
   
    c_ids.each_with_index do |id, index_i|
      h_conds = output[id]
      aaData[index_i] = []
      aaData[index_i][0] = id
      html_line = "<tr><td>" << id.to_s << "</td>"
      group_props.each_with_index do |gp, index_j|
        v = h_conds[gp]
        if !v.nil? 
          aaData[index_i][index_j + 1] = v
          if gp == "tag"
            html_line << "<td class=\"tag-data\">" << v.join(', ') << "</td>"
          else
            html_line << "<td>" << v.join(', ') << "</td>"
          end
        else
          aaData[index_i][index_j + 1] = ""
          html_line << "<td>" << " " << "</td>"
        end          
      end
      html_ret << html_line << "</tr>"
    end

    html_ret

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

end
