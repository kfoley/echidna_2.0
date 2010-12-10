module Blacklight::Solr::Document::ConditionExport

    def self.extended(document)
        document.will_export_as(:xls, "application/xls")
        document.will_export_as(:csv, "application/csv")
    end 

    def export_as_xls

    end

    def export_as_csv

    end

end