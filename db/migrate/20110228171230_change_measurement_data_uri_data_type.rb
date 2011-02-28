class ChangeMeasurementDataUriDataType < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `measurement_datas` modify `uri` TEXT"
  end

  def self.down
  end
end
