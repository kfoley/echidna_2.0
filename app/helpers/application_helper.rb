require 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
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

  def render_index_field_value args
    value = args[:value]
    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]

    render_field_value value
  end

  def render_get_field_property args
    value = args[:value]
    value ||= args[:document].get(args[:field], :sep => nil) if args[:document] and args[:field]

    keys ||= args[:document].get("property_key", :sep => nil) if args[:document] and args[:field]
    vals ||= args[:document].get("property_value", :sep => nil) if args[:document] and args[:field]

    html_ret = ''
    index = 0
    while index < keys.length
      html_line = "<tr><td>" + keys[index].to_s + "</td> <td>" + vals[index].to_s + "</td></tr>" 
      html_ret << html_line
      index += 1
    end

    html_ret

  end

end
