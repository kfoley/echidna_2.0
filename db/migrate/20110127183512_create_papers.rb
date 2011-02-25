class CreatePapers < ActiveRecord::Migration
  def self.up
    create_table :papers do |t|
      t.string :title
      t.string :url
      t.string :authors
      t.text :abstract
      t.string :short_name

      t.timestamps
    end
  end

  def self.down
    drop_table :papers
  end
end
