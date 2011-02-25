class CreateMeasurementVocabs < ActiveRecord::Migration
  def self.up
    create_table :measurement_vocabs do |t|
      t.integer :measurement_id
      t.integer :vocabulary_entries_id

      t.timestamps
    end
  end

  def self.down
    drop_table :measurement_vocabs
  end
end
