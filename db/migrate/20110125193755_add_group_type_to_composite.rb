class AddGroupTypeToComposite < ActiveRecord::Migration
  def self.up
    add_column :composites, :group_type, :string
  end

  def self.down
    remove_column :composites, :group_type
  end
end
