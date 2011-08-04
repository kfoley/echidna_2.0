require 'rubygems'
require 'active_record'
require 'net/http'
require 'uri'
require 'cgi'
require 'json'
require 'csv'

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    #:encoding => 'uft8',
    :database => 'echidna2_production',
    :username => 'kfoley',
    :password => 'kfoley',
    :host => 'localhost'
)

class Composite < ActiveRecord::Base
  has_many :composites_properties
  has_many :properties, :through => :composites_properties
end 

class Condition < Composite
  has_many :groupings, :foreign_key => "child_id"
  has_many :condition_groups, :through => :groupings
  has_one :measurement_data
end 

class MeasurementDatas < ActiveRecord::Base
end

#test = MeasurementDatas.find_by_sql ["SELECT md.uri, c.name FROM composites c, measurement_datas md WHERE c.id=md.condition_id AND c.id=1835"]
#puts test.to_json

class Lambdas
  attr_reader :data

  def initialize(filename)
    read_file(filename)
  end

  def read_file(filename)
    @data = []
    File.open(filename) do |file|
      file.each_line do |line|
        # get rid of the trailing newline
        line = line.strip
        @data << line
      end
    end #File.open

    # read each condition name and get its uri
    is_genes = 0
    all_data = []
    data.each do |condition_name|
      uri = MeasurementDatas.find_by_sql ["SELECT md.uri FROM composites c, measurement_datas md WHERE c.id=md.condition_id AND c.name=?", condition_name]
      uri.each do |h|
        h.attributes.each do |attr_name, attr_value|
          this_uri = attr_value
          run_data = get_lambdas_ratios(this_uri)
          all_data << run_data
        end
      end
    end

    write_to_file(all_data)

  end #read_file

  def get_lambdas_ratios(cond_uri)
    uri_hash = {}
    uri_arr = []
    data_hash = {}
    all_data_array = []

    #url encode uri
    encoded_uri = CGI.escape(cond_uri)
    
    # setup proper format for pebble
    uri_hash["uri"] = encoded_uri
    uri_arr << uri_hash

    host = "bragi.systemsbiology.net"
    path = "/pebble/api/1/measurements?query=" + uri_arr.to_json
    response =  Net::HTTP.get(host, path, port=8081)
    result = JSON.parse(response)


    # grab ratios and lambdas for each condition
    ratios = result["data"].map { |u| u[0]["ratio"] }
    lambdas = result["data"].map { |u| u[0]["lambda"] }    

    data_hash["run"] = result["conditions"]
    data_hash["genes"] = result["genes"]
    data_hash["ratios"] = ratios
    data_hash["lambdas"] = lambdas

    #all_data_array << data_hash

    return data_hash

  end #get_lambdas_ratios()

  def write_to_file(all_data)
    # sort all_data according to run name
    all_data = all_data.sort_by { |item| item["run"] }

    iter = 0
    run_names = ""
    r_data_set = []
    l_data_set = []
    genes = all_data[0]["genes"]
    r_data_set << genes
    l_data_set << genes
    while (iter < all_data.length)
      #genes = all_data[iter]["genes"]
      ratios = all_data[iter]["ratios"]
      lambdas = all_data[iter]["lambdas"]

      # form RATIO data set
      #r_data_set << genes
      r_data_set << ratios

      # form LAMBDA data set
      #l_data_set << genes
      l_data_set << lambdas

      # form a row of all condition names
      run_names << "\t" + all_data[iter]["run"].to_s

      iter += 1
    end

    r_trans = r_data_set.transpose
    l_trans = l_data_set.transpose

    # write RATIO data to RATIO file
    File.open('ratio.txt', 'a') do |csv|
      csv.write("#{run_names}\n")
      r_trans.each { |row|
        row.each { |col|
          #case col
          #when Float 
          #  newcol = sprintf("%3.4f", col)
          #else
          #  newcol = col
          #end
          csv.write("#{col}\t")
        }
        csv.write("\n")
      }      
    end

    # write LAMBDA data to LAMBDA file
    File.open('lambda.txt', 'a') do |csv|
      csv.write("#{run_names}\n")
      l_trans.each { |row|
        row.each { |col|
          #case col
          #when Float 
          #  newcol = sprintf("%3.4f", col)
          #else
          #  newcol = col
          #end
          csv.write("#{col}\t")
        }
        csv.write("\n")
      }      
    end
  end #write_to_file()

end

Lambdas.new("deep_recent_data.txt")
