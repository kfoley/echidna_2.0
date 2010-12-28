# Mixin module for our lab's exporters. We mix it in at config/initializers/blacklight_config.rb
#
# our 'this' object is an instance of Blacklight::Solr::Document
# This means we can access the data in the following way
# this._source - a hash of all values, we can use it to extract the available keys
# this.has? - basically a contains_key? function
# this.get? - retrieve the value from the _source hash
module ConditionExport

    def self.extended(document)
      document.will_export_as(:csv, "text/csv")
    end

    def export_as_csv
      out = ""
      if has?("groups") then
        out += get("groups")
      end
      out
    end
end
