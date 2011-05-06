require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql',
    #:encoding => 'uft8',
    :database => 'echidna2_production',
    :username => 'kfoley',
    :password => 'kfoley',
    :host => 'localhost'
)

class Species < ActiveRecord::Base
  has_many :species_vocabularies
  has_many :vocabulary_entries, :through => :species_vocabularies
end

class SpeciesVocabulary < ActiveRecord::Base
  belongs_to :species
  belongs_to :vocabulary_entry
end

class VocabularyEntry < ActiveRecord::Base
  has_many :species_vocabularies
  has_many :species, :through => :species_vocabularies
end

class Property < ActiveRecord::Base
  has_many :composites_properties
  has_many :composites, :through => :composites_properties
end

class Composite < ActiveRecord::Base
  has_many :composites_properties
  has_many :properties, :through => :composites_properties
end 

class CompositesProperties < ActiveRecord::Base
  belongs_to :composite
  belongs_to :property
end

class Condition < Composite
  has_many :groupings, :foreign_key => "child_id"
  has_many :condition_groups, :through => :groupings
  has_one :measurement_data
end 

class ConditionGroup < Composite
  has_many :groupings, :foreign_key => "parent_id"
  has_many :conditions, :through => :groupings
end 

# @test = []
test  = Composite.find_by_name("sDura3_pZn_d0.050mM_t-015m_vs_NRC-1h1.sig")
#puts test.to_json


class EnvMap
  attr_reader :headers, :data
  
  def initialize(filename)
    read_envmap_file(filename)
  end
  
  def read_envmap_file(filename)
    @headers = []
    @data = []
    File.open(filename) do |file|
      file.each_line do |line|
        if file.lineno == 3
          @headers = line.split("\t")
        end

        if file.lineno > 3
        #if file.lineno == 2
          @data << line
          #puts "#{line}"
        end
      end
    end
    
    @cond = []
    counter = 0
    add_to_db = []
    doesnt_match = []
    dont_add_to_db = []
    data.each do | value |
      cond_terms = value.split("\t")

      # get the db data based on condition name
      db_cond_id  = Composite.find_by_name(cond_terms[0]).id
      #db_cond_id  = Composite.find_by_name("feso4__0005m_vs_NRC-1b").id
      db_props = Composite.find_by_sql  ["SELECT cp.id as cp_id, p.key, p.value, p.unit, c.id as comp_id FROM composites c INNER JOIN composites_properties cp ON cp.composite_id=c.id INNER JOIN properties p ON p.id=cp.property_id WHERE c.id=?", db_cond_id]
      
      cond_name = cond_terms[0]
      # excel data
      cond_terms.each_with_index do | val, index |
        if index > 0
          if ((val != "NA") and (val != ""))

            xl_term = headers[index].chomp
            val = val.chomp
            add_term = ''
            dont_add = ''
            mismatch = ''
            db_props.each do | row_hash |
              if xl_term == row_hash.key
                if val == row_hash.value
                  # in database already and a match; do nothing
                else
                  if xl_term == "tag"
                    # don't need to deal with tags. do nothing; skip
                  else
                    # Needs to be updated in the database
                    not_match = cond_name + "=" + xl_term + "=" + val + "=" + row_hash.comp_id + "=" + row_hash.key + "=" + row_hash.value + "=" + row_hash.unit.to_s + "=" + row_hash.cp_id
                    #puts not_match
                    update_database_entry(row_hash.cp_id, xl_term, val)
                  end
                end
                mismatch = not_match
                dont_add = xl_term
              else
                if dont_add != ''
                  # do nothing
                else
                  # Needs to go in the database
                  add_term = row_hash.comp_id + "=" + xl_term + "=" + val
                end
              end
            end
            doesnt_match << mismatch
            dont_add_to_db << dont_add
            add_to_db << add_term            
          end
        end
      end
      add_to_db = add_to_db - dont_add_to_db
    end # end of data.each


    add_to_db.each do | row |
      items = row.split("=")

      # setup for adding new vocabulary entry if it doesn't exist
      species = "Halobacterium sp. NRC-1"
      sp_id = Species.find_by_name(species)

      # get metadata id
      meta_id = VocabularyEntry.find_by_key(items[1])

      if items[1].include? 'KO'
        type = "genetic"
      elsif items[1].include? 'ura3'
        type = "genetic"
      else
        type = "environmental"
      end

      # create composite object
      composite_id = items[0].to_i
      composite_obj = Composite.find_by_id(composite_id)

      #property_id = Property.find_by_key(items[1])
      #property_id = property_id.id

      #test = CompositesProperties.where(:property_id => property_id, :composite_id => composite_id)
      test = Composite.find_by_sql  ["SELECT cp.id as cp_id, p.key, p.value, p.unit, c.id as comp_id FROM composites c INNER JOIN composites_properties cp ON cp.composite_id=c.id INNER JOIN properties p ON p.id=cp.property_id WHERE c.id=?", composite_id]
      ok = true
      test.each do | hs_row |
        #puts hs_row.key
        if hs_row.key == items[1]
          puts hs_row.key
          puts hs_row.cp_id
          puts "don't add to the db; already in there"
          ok = false
        end
        #puts row.has_value?(items[1])
      end
      #puts ok
      #puts test.to_json
      #puts test.key
      #puts items[1]
      #if test.empty?
      #  puts "add"
      #else
      #  puts "dont add"
      #  puts test
      #end


      if ok
        puts "adding"
        Property.transaction do
          # add metadata term if not in db
          if meta_id.nil?
            if items[1] == "Optical density"
            else
              VocabularyEntry.create(:key => items[1], :vocab_type => type)
              id = VocabularyEntry.find_by_key(items[1])
              SpeciesVocabulary.create(:species => sp_id,
                                       :vocabulary_entry => id)
              #puts "key = " + items[1]
              #puts "type = " + type
            end
          end
          
          prop = Property.create(:key   => items[1],
                                 :value => items[2],
                                 :unit  => "")
          CompositesProperties.create(:property        => prop,
                                      :composite       => composite_obj,
                                      :is_observation  => 0,
                                      :is_perturbation => 0)
          #raise ActiveRecord::Rollback
        end
      else
        # do nothing
      end
    end

  end # end of read_envmap_file
  

  def update_database_entry(cp_id, xl_term, xl_val)
    prop_id = CompositesProperties.find_by_id(cp_id).property_id
    Property.transaction do
      prop = Property.where(:id => prop_id)[0]
      prop.value = xl_val
      prop.save
      #raise ActiveRecord::Rollback
    end
  end
end # end of Envmap

#EnvMap.new("envmapKBedits_071610.txt")
EnvMap.new("envmapKB071610_LP20100928.txt")
