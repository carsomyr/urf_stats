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

ActiveRecord::Schema.define(version: 6) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "challenge_bucket_counters", force: :cascade do |t|
    t.string   "region",      limit: 4, null: false
    t.datetime "bucket_time",           null: false
  end

  add_index "challenge_bucket_counters", ["region"], name: "index_challenge_bucket_counters_on_region", unique: true, using: :btree

  create_table "riot_api_matches", force: :cascade do |t|
    t.integer  "match_id",      limit: 8, null: false
    t.string   "region",        limit: 4, null: false
    t.json     "content"
    t.datetime "creation_time"
    t.integer  "duration"
  end

  add_index "riot_api_matches", ["creation_time"], name: "index_riot_api_matches_on_creation_time", using: :btree
  add_index "riot_api_matches", ["match_id", "region"], name: "index_riot_api_matches_on_match_id_and_region", unique: true, using: :btree

  create_table "riot_api_static_entities", force: :cascade do |t|
    t.string "type",       null: false
    t.string "name",       null: false
    t.string "image_path", null: false
  end

  add_index "riot_api_static_entities", ["id", "type"], name: "index_riot_api_static_entities_on_id_and_type", unique: true, using: :btree

  create_table "stats", force: :cascade do |t|
    t.string   "region",                    limit: 4,             null: false
    t.datetime "start_time",                                      null: false
    t.integer  "interval",                            default: 2
    t.integer  "n_matches",                                       null: false
    t.integer  "average_duration",                                null: false
    t.integer  "average_n_kills",                                 null: false
    t.integer  "average_n_assists",                               null: false
    t.integer  "average_time_first_blood",                        null: false
    t.integer  "average_gold",                                    null: false
    t.integer  "average_n_minions_killed",                        null: false
    t.integer  "average_n_dragons",                               null: false
    t.integer  "average_time_first_dragon",                       null: false
    t.integer  "average_n_barons",                                null: false
    t.integer  "average_time_first_baron",                        null: false
  end

  add_index "stats", ["region", "start_time", "interval"], name: "index_stats_on_region_and_start_time_and_interval", unique: true, using: :btree

end
