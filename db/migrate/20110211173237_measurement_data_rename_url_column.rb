class MeasurementDataRenameUrlColumn < ActiveRecord::Migration
  def self.up
    rename_column :measurement_datas, :url, :uri
  end

  def self.down
  end
end
