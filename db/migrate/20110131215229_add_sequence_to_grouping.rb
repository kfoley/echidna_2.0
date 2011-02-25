class AddSequenceToGrouping < ActiveRecord::Migration
  def self.up
    add_column :groupings, :sequence, :integer
  end

  def self.down
    remove_column :groupings, :sequence
  end
end
