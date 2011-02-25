class AddCompositeIdToProperty < ActiveRecord::Migration
  def self.up
    add_column :properties, :composite_id, :integer
  end

  def self.down
    remove_column :properties, :composite_id
  end
end
