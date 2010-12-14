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
end
