# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "challenge_bucket_counters", force: :cascade do |t|
    t.string   "region",      limit: 4, null: false
    t.datetime "bucket_time",           null: false
  end

  add_index "challenge_bucket_counters", ["region"], name: "index_challenge_bucket_counters_on_region", unique: true, using: :btree

  create_table "entity_integers", force: :cascade do |t|
    t.integer "stat_id",              null: false
    t.integer "entity_id",            null: false
    t.string  "value_type",           null: false
    t.integer "value",      limit: 8, null: false
  end

  add_index "entity_integers", ["entity_id"], name: "index_entity_integers_on_entity_id", using: :btree
  add_index "entity_integers", ["stat_id", "entity_id", "value_type"], name: "index_entity_counts_uniqueness", unique: true, using: :btree
  add_index "entity_integers", ["stat_id"], name: "index_entity_integers_on_stat_id", using: :btree
  add_index "entity_integers", ["value_type"], name: "index_entity_integers_on_value_type", using: :btree

  create_table "item_purchase_counts", force: :cascade do |t|
    t.integer "stat_id",      null: false
    t.integer "purchaser_id", null: false
    t.integer "item_id",      null: false
    t.integer "value",        null: false
  end

  add_index "item_purchase_counts", ["item_id", "purchaser_id"], name: "index_item_purchase_counts_on_item_id_and_purchaser_id", using: :btree
  add_index "item_purchase_counts", ["item_id"], name: "index_item_purchase_counts_on_item_id", using: :btree
  add_index "item_purchase_counts", ["purchaser_id"], name: "index_item_purchase_counts_on_purchaser_id", using: :btree
  add_index "item_purchase_counts", ["stat_id", "purchaser_id", "item_id"], name: "index_item_purchase_counts_uniqueness", unique: true, using: :btree
  add_index "item_purchase_counts", ["stat_id"], name: "index_item_purchase_counts_on_stat_id", using: :btree

  create_table "kill_assist_counts", force: :cascade do |t|
    t.integer "stat_id",     null: false
    t.integer "killer_id",   null: false
    t.integer "assister_id"
    t.integer "value",       null: false
    t.integer "n_matches",   null: false
  end

  add_index "kill_assist_counts", ["assister_id"], name: "index_kill_assist_counts_on_assister_id", using: :btree
  add_index "kill_assist_counts", ["killer_id", "assister_id"], name: "index_kill_assist_counts_on_killer_id_and_assister_id", using: :btree
  add_index "kill_assist_counts", ["killer_id"], name: "index_kill_assist_counts_on_killer_id", using: :btree
  add_index "kill_assist_counts", ["stat_id", "killer_id", "assister_id"], name: "index_kill_assists_counts_uniqueness", unique: true, using: :btree
  add_index "kill_assist_counts", ["stat_id"], name: "index_kill_assist_counts_on_stat_id", using: :btree

  create_table "riot_api_matches", force: :cascade do |t|
    t.integer  "match_id",      limit: 8, null: false
    t.string   "region",        limit: 4, null: false
    t.json     "content"
    t.datetime "creation_time"
    t.integer  "duration"
  end

  add_index "riot_api_matches", ["creation_time"], name: "index_riot_api_matches_on_creation_time", using: :btree
  add_index "riot_api_matches", ["match_id", "region"], name: "index_riot_api_matches_on_match_id_and_region", unique: true, using: :btree
  add_index "riot_api_matches", ["match_id"], name: "index_riot_api_matches_on_match_id", using: :btree
  add_index "riot_api_matches", ["region"], name: "index_riot_api_matches_on_region", using: :btree

  create_table "riot_api_static_entities", force: :cascade do |t|
    t.string  "type",                 null: false
    t.string  "name",                 null: false
    t.string  "image_path",           null: false
    t.integer "entity_id",  limit: 8, null: false
  end

  add_index "riot_api_static_entities", ["entity_id", "type"], name: "index_riot_api_static_entities_on_entity_id_and_type", unique: true, using: :btree
  add_index "riot_api_static_entities", ["entity_id"], name: "index_riot_api_static_entities_on_entity_id", using: :btree
  add_index "riot_api_static_entities", ["type"], name: "index_riot_api_static_entities_on_type", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "stats", force: :cascade do |t|
    t.string   "region",                  limit: 4,             null: false
    t.datetime "start_time",                                    null: false
    t.integer  "interval",                          default: 2
    t.integer  "n_matches",                                     null: false
    t.integer  "total_duration",          limit: 8,             null: false
    t.integer  "total_kills",                                   null: false
    t.integer  "total_assists",                                 null: false
    t.integer  "total_time_first_blood",  limit: 8,             null: false
    t.integer  "total_gold",              limit: 8,             null: false
    t.integer  "total_minions_killed",                          null: false
    t.integer  "total_dragons",                                 null: false
    t.integer  "total_time_first_dragon", limit: 8,             null: false
    t.integer  "total_barons",                                  null: false
    t.integer  "total_time_first_baron",  limit: 8,             null: false
    t.integer  "total_champion_level",                          null: false
    t.integer  "n_first_blood_games",                           null: false
    t.integer  "n_first_dragon_games",                          null: false
    t.integer  "n_first_baron_games",                           null: false
  end

  add_index "stats", ["region", "start_time", "interval"], name: "index_stats_on_region_and_start_time_and_interval", unique: true, using: :btree
  add_index "stats", ["region"], name: "index_stats_on_region", using: :btree
  add_index "stats", ["start_time"], name: "index_stats_on_start_time", using: :btree

  add_foreign_key "entity_integers", "riot_api_static_entities", column: "entity_id", on_delete: :cascade
  add_foreign_key "entity_integers", "stats", on_delete: :cascade
  add_foreign_key "item_purchase_counts", "riot_api_static_entities", column: "item_id", on_delete: :cascade
  add_foreign_key "item_purchase_counts", "riot_api_static_entities", column: "purchaser_id", on_delete: :cascade
  add_foreign_key "item_purchase_counts", "stats", on_delete: :cascade
  add_foreign_key "kill_assist_counts", "riot_api_static_entities", column: "assister_id", on_delete: :cascade
  add_foreign_key "kill_assist_counts", "riot_api_static_entities", column: "killer_id", on_delete: :cascade
  add_foreign_key "kill_assist_counts", "stats", on_delete: :cascade
end
