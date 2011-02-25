class AddFlagsToCompositesProperties < ActiveRecord::Migration
  def self.up
    add_column :composites_properties, :is_observation, :boolean
    add_column :composites_properties, :is_perturbation, :boolean
  end

  def self.down
    remove_column :composites_properties, :is_perturbation
    remove_column :composites_properties, :is_observation
  end
end
