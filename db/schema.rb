# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110218230927) do

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.text     "url"
    t.string   "document_id"
    t.string   "title"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "citations", :force => true do |t|
    t.integer  "paper_id"
    t.integer  "condition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "composites", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.integer  "importer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "composites_properties", :force => true do |t|
    t.integer  "composite_id"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_observation"
    t.boolean  "is_perturbation"
  end

  add_index "composites_properties", ["composite_id", "property_id"], :name => "uc_comp_prop", :unique => true

  create_table "condition_mapping", :id => false, :force => true do |t|
    t.integer "original_id"
    t.integer "mapped_id"
  end

  create_table "group_mapping", :id => false, :force => true do |t|
    t.integer "original_id"
    t.integer "mapped_id"
  end

  create_table "groupings", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence"
  end

  add_index "groupings", ["parent_id", "child_id"], :name => "uc_groupings", :unique => true

  create_table "knockout_mapping", :id => false, :force => true do |t|
    t.integer "original_id"
    t.integer "mapped_id"
  end

  create_table "measurement_datas", :force => true do |t|
    t.integer  "condition_id"
    t.string   "uri"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "measurement_datas", ["condition_id", "uri"], :name => "uc_meas_data", :unique => true
  add_index "measurement_datas", ["uri"], :name => "uc_meas_data_uri", :unique => true

  create_table "measurement_vocabs", :force => true do |t|
    t.integer  "measurement_id"
    t.integer  "vocabulary_entries_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "measurement_vocabs", ["measurement_id", "vocabulary_entries_id"], :name => "uc_meas_vocab", :unique => true

  create_table "measurements", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "observation_mapping", :id => false, :force => true do |t|
    t.integer "original_id"
    t.integer "mapped_id"
  end

  create_table "paper_mapping", :id => false, :force => true do |t|
    t.integer "original_id"
    t.integer "mapped_id"
  end

  create_table "papers", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "authors"
    t.text     "abstract"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "perturbation_mapping", :id => false, :force => true do |t|
    t.integer "original_id"
    t.integer "mapped_id"
  end

  create_table "properties", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", :force => true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

  create_table "species", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "species_mapping", :id => false, :force => true do |t|
    t.integer "original_id"
    t.integer "mapped_id"
  end

  create_table "species_vocabularies", :force => true do |t|
    t.integer  "species_id"
    t.integer  "vocabulary_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "species_vocabularies", ["species_id", "vocabulary_entry_id"], :name => "uc_spec_vocab", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_search_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vocabulary_entries", :force => true do |t|
    t.string   "key"
    t.string   "vocab_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vocabulary_entries", ["key", "vocab_type"], :name => "uc_vocab", :unique => true

end
