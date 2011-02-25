class CreateMeasurementDatas < ActiveRecord::Migration
  def self.up
    create_table :measurement_datas do |t|
      t.integer :condition_id
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :measurement_datas
  end
end
