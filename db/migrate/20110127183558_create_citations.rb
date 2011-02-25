class CreateCitations < ActiveRecord::Migration
  def self.up
    create_table :citations do |t|
      t.integer :paper_id
      t.integer :condition_id

      t.timestamps
    end
  end

  def self.down
    drop_table :citations
  end
end
