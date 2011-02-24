class VocabularyEntry < ActiveRecord::Base
  has_many :species_vocabularies
  has_many :species, :through => :species_vocabularies
end
