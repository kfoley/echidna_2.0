class ChangeCompositeNameDataType < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `composites` modify `name` TEXT"
  end

  def self.down
  end
end
