module ConditionExport

    def self.extended(document)
      document.will_export_as(:csv, "text/csv")
    end 

    def export_as_csv
      "this is a CSV file"
    end

end
