class CreateCompositesProperties < ActiveRecord::Migration
  def self.up
    create_table :composites_properties do |t|
      t.integer :composite_id
      t.integer :property_id

      t.timestamps
    end
  end

  def self.down
    drop_table :composites_properties
  end
end
