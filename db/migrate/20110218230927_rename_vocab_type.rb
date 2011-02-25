class RenameVocabType < ActiveRecord::Migration
  def self.up
    rename_column :vocabulary_entries, :type, :vocab_type
  end

  def self.down
  end
end
