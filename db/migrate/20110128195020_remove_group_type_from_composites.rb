class RemoveGroupTypeFromComposites < ActiveRecord::Migration
  def self.up
    remove_column :composites, :group_type
  end

  def self.down
    add_column :composites, :group_type, :string
  end
end
