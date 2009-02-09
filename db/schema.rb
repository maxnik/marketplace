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

ActiveRecord::Schema.define(:version => 20090206072004) do

  create_table "articles", :force => true do |t|
    t.string   "title",                    :null => false
    t.text     "body",                     :null => false
    t.integer  "length",     :limit => 11
    t.integer  "buyer_id",   :limit => 11
    t.integer  "author_id",  :limit => 11, :null => false
    t.integer  "owner_id",   :limit => 11
    t.string   "owner_type"
    t.integer  "price",      :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "url_name"
    t.integer  "parent_id",      :limit => 11
    t.integer  "articles_count", :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id",    :limit => 11
    t.integer  "recipient_id", :limit => 11
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.integer  "owner_id",     :limit => 11
    t.string   "owner_type"
    t.integer  "parent_id",    :limit => 11
    t.integer  "size",         :limit => 11
    t.integer  "width",        :limit => 11
    t.integer  "height",       :limit => 11
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "propositions", :force => true do |t|
    t.integer  "sender_id",  :limit => 11
    t.text     "body"
    t.integer  "task_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.integer  "price",              :limit => 11
    t.integer  "customer_id",        :limit => 11,                :null => false
    t.integer  "copywriter_id",      :limit => 11
    t.integer  "propositions_count", :limit => 11, :default => 0
    t.integer  "articles_count",     :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "wmz"
    t.datetime "last_login_at"
    t.datetime "last_tasks_at"
    t.datetime "last_messages_at"
    t.integer  "forsale_articles_count",    :limit => 11,  :default => 0
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
