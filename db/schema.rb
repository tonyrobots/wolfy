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

ActiveRecord::Schema.define(version: 20141221020351) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.text     "body"
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "game_id"
    t.integer  "target_id"
    t.string   "target_role"
  end

  add_index "comments", ["game_id"], name: "index_comments_on_game_id", using: :btree
  add_index "comments", ["player_id"], name: "index_comments_on_player_id", using: :btree

  create_table "event_logs", force: true do |t|
    t.integer  "game_id"
    t.text     "text"
    t.integer  "actor"
    t.integer  "target"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "turn"
  end

  add_index "event_logs", ["game_id"], name: "index_event_logs_on_game_id", using: :btree

  create_table "games", force: true do |t|
    t.string   "name"
    t.integer  "turn",        default: 0
    t.string   "state",       default: "Unstarted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.text     "description"
    t.string   "winner"
    t.boolean  "nightstart",  default: true
  end

  create_table "messages", force: true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.text     "content"
    t.text     "recipient_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["game_id"], name: "index_messages_on_game_id", using: :btree

  create_table "moves", force: true do |t|
    t.integer  "game_id"
    t.string   "action"
    t.integer  "player_id"
    t.integer  "turn"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "moves", ["game_id"], name: "index_moves_on_game_id", using: :btree
  add_index "moves", ["player_id"], name: "index_moves_on_player_id", using: :btree

  create_table "players", force: true do |t|
    t.string   "alias"
    t.string   "role"
    t.boolean  "alive",      default: true
    t.string   "last_move"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "knowledge",  default: [],   array: true
  end

  add_index "players", ["game_id"], name: "index_players_on_game_id", using: :btree
  add_index "players", ["user_id"], name: "index_players_on_user_id", using: :btree

  create_table "user_stats", force: true do |t|
    t.integer "played_count",      default: 0
    t.integer "wins_count",        default: 0
    t.integer "survived_count",    default: 0
    t.integer "user_id",                       null: false
    t.integer "wolf_count",        default: 0
    t.integer "seer_count",        default: 0
    t.integer "angel_count",       default: 0
    t.integer "illusionist_count", default: 0
    t.integer "villager_count",    default: 0
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.string   "username",               default: ""
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "votes", force: true do |t|
    t.integer  "game_id"
    t.integer  "voter_id"
    t.integer  "votee_id"
    t.integer  "turn"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["game_id"], name: "index_votes_on_game_id", using: :btree
  add_index "votes", ["votee_id"], name: "index_votes_on_votee_id", using: :btree
  add_index "votes", ["voter_id"], name: "index_votes_on_voter_id", using: :btree

end
