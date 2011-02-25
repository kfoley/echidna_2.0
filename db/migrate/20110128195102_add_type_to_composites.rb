class AddTypeToComposites < ActiveRecord::Migration
  def self.up
    add_column :composites, :type, :string
  end

  def self.down
    remove_column :composites, :type
  end
end
