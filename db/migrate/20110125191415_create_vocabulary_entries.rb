class CreateVocabularyEntries < ActiveRecord::Migration
  def self.up
    create_table :vocabulary_entries do |t|
      t.string :key
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :vocabulary_entries
  end
end
