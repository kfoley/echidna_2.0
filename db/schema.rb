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

ActiveRecord::Schema.define(:version => 20100518163955) do

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
    t.integer "paper_id"
    t.integer "condition_id"
  end

  create_table "condition_groupings", :force => true do |t|
    t.integer  "condition_id"
    t.integer  "condition_group_id"
    t.integer  "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "condition_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_time_series"
    t.integer  "owner_id"
    t.integer  "importer_id"
    t.integer  "type"
  end

  create_table "conditions", :force => true do |t|
    t.integer  "experiment_id"
    t.string   "name"
    t.integer  "sequence"
    t.boolean  "has_data"
    t.integer  "forward_slide_number"
    t.integer  "reverse_slide_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "original_name"
    t.integer  "sbeams_project_id"
    t.string   "sbeams_timestamp"
    t.integer  "species_id"
    t.integer  "gwap2_id"
    t.integer  "reference_sample_id"
    t.integer  "owner_id"
    t.integer  "importer_id"
    t.integer  "growth_media_recipe_id"
    t.integer  "last_updated_by"
  end

  add_index "conditions", ["id"], :name => "index_conditions_on_id"

  create_table "controlled_vocab_items", :force => true do |t|
    t.string   "name"
    t.boolean  "approved"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_types", :force => true do |t|
    t.string "name"
  end

  create_table "environmental_perturbation_associations", :force => true do |t|
    t.integer "environmental_perturbation_id"
    t.integer "condition_id"
  end

  create_table "environmental_perturbations", :force => true do |t|
    t.string "perturbation"
  end

  create_table "features", :force => true do |t|
    t.integer "track_id",     :limit => 8
    t.float   "value"
    t.integer "data_type",    :limit => 8
    t.integer "gene_id",      :limit => 8
    t.integer "location_id",  :limit => 8
    t.integer "condition_id", :limit => 8
    t.integer "sequence_id",  :limit => 8
    t.integer "start",        :limit => 8
    t.integer "end",          :limit => 8
    t.boolean "strand"
  end

  add_index "features", ["condition_id"], :name => "index_features_on_condition_id"
  add_index "features", ["data_type"], :name => "index_features_on_data_type"
  add_index "features", ["gene_id"], :name => "index_features_on_gene_id"

  create_table "genes", :force => true do |t|
    t.string "name"
    t.string "alias"
    t.string "gene_name"
  end

  add_index "genes", ["id"], :name => "index_genes_on_id"

  create_table "group_attributes", :force => true do |t|
    t.integer "group_id"
    t.string  "key"
    t.string  "string_value"
    t.integer "int_value"
    t.float   "float_value"
  end

  create_table "growth_media_recipes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  create_table "knockout_associations", :force => true do |t|
    t.integer "knockout_id"
    t.integer "condition_id"
  end

  create_table "knockouts", :force => true do |t|
    t.string  "gene"
    t.integer "ranking"
    t.string  "control_for"
    t.integer "parent_id"
  end

  create_table "logged_actions", :force => true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "observations", :force => true do |t|
    t.integer  "condition_id"
    t.integer  "name_id"
    t.string   "string_value"
    t.integer  "int_value"
    t.float    "float_value"
    t.integer  "units_id"
    t.boolean  "is_measurement"
    t.boolean  "is_time_measurement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "boolean_value"
  end

  create_table "papers", :force => true do |t|
    t.string "title"
    t.string "url"
    t.string "authors"
    t.text   "abstract"
    t.string "short_name"
  end

  create_table "reference_samples", :force => true do |t|
    t.string "name"
  end

  create_table "relationship_types", :force => true do |t|
    t.string   "name"
    t.string   "inverse"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", :force => true do |t|
    t.integer "relationship_type_id"
    t.integer "group1"
    t.integer "group2"
    t.string  "note"
  end

  create_table "search_terms", :force => true do |t|
    t.string   "word"
    t.integer  "group_id",      :limit => 8
    t.integer  "condition_id",  :limit => 8
    t.datetime "creation_time"
    t.integer  "int_timestamp"
  end

  create_table "searches", :force => true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

  create_table "species", :force => true do |t|
    t.string "name"
    t.string "alternate_name"
  end

  create_table "sub_searches", :force => true do |t|
    t.integer "user_search_id"
    t.string  "environmental_perturbation"
    t.string  "knockout"
    t.string  "free_text_term"
    t.boolean "include_related"
    t.boolean "refine"
    t.string  "last_results_option_selected"
    t.integer "sequence"
  end

  create_table "tag_categories", :force => true do |t|
    t.string "category_name"
  end

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

  create_table "tags_echid", :force => true do |t|
    t.integer "condition_id",    :limit => 8
    t.string  "tag"
    t.boolean "auto"
    t.boolean "is_alias"
    t.string  "alias_for"
    t.integer "tag_category_id", :limit => 8
    t.integer "user_id"
    t.integer "sequence"
  end

  create_table "tmp_table_1280443635", :force => true do |t|
    t.integer "cid"
  end

  add_index "tmp_table_1280443635", ["cid"], :name => "cid_index"
  add_index "tmp_table_1280443635", ["id"], :name => "id_index"

  create_table "tmp_table_1280445079", :force => true do |t|
    t.integer "cid"
  end

  add_index "tmp_table_1280445079", ["cid"], :name => "cid_index"
  add_index "tmp_table_1280445079", ["id"], :name => "id_index"

  create_table "tmp_table_1280445637", :force => true do |t|
    t.integer "cid"
  end

  add_index "tmp_table_1280445637", ["cid"], :name => "cid_index"
  add_index "tmp_table_1280445637", ["id"], :name => "id_index"

  create_table "tmp_table_1280446349", :force => true do |t|
    t.integer "cid"
  end

  add_index "tmp_table_1280446349", ["cid"], :name => "cid_index"
  add_index "tmp_table_1280446349", ["id"], :name => "id_index"

  create_table "tmp_table_1280446350", :force => true do |t|
    t.integer "cid"
  end

  add_index "tmp_table_1280446350", ["cid"], :name => "cid_index"
  add_index "tmp_table_1280446350", ["id"], :name => "id_index"

  create_table "tmp_table_1280448498", :force => true do |t|
    t.integer "cid"
  end

  add_index "tmp_table_1280448498", ["cid"], :name => "cid_index"
  add_index "tmp_table_1280448498", ["id"], :name => "id_index"

  create_table "units", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_searches", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "is_structured"
    t.integer  "user_id"
    t.string   "free_text_search_terms"
  end

  create_table "users", :force => true do |t|
    t.string   "login",             :default => "", :null => false
    t.string   "email"
    t.string   "crypted_password"
    t.text     "last_search_url"
    t.datetime "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "current_login_at"
  end

  create_table "users_echid", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.date     "last_login_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "validated"
    t.string   "first_name"
    t.string   "last_name"
  end

end
