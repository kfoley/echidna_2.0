class CreateComposites < ActiveRecord::Migration
  def self.up
    create_table :composites do |t|
      t.string :name
      t.integer :owner_id
      t.integer :importer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :composites
  end
end
