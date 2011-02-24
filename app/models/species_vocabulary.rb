class SpeciesVocabulary < ActiveRecord::Base
  belongs_to :species
  belongs_to :vocabulary_entry
end
