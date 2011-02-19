class Species < ActiveRecord::Base
  has_many :species_vocabularies
  has_many :vocabulary_entries, :through => :species_vocabularies
end
