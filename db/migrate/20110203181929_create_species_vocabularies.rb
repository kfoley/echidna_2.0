class CreateSpeciesVocabularies < ActiveRecord::Migration
  def self.up
    create_table :species_vocabularies do |t|
      t.integer :species_id
      t.integer :vocabulary_entry_id

      t.timestamps
    end
  end

  def self.down
    drop_table :species_vocabularies
  end
end
