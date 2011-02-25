class RemoveCompositeIdFromProperties < ActiveRecord::Migration
  def self.up
    remove_column :properties, :composite_id
  end

  def self.down
    add_column :properties, :composite_id, :integer
  end
end
