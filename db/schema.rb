# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_09_02_210635) do
  create_table "accounts", force: :cascade do |t|
    t.integer "owner_id", limit: 10, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "site_name", limit: 255, default: "", null: false
    t.string "host_name", default: "", null: false
    t.text "settings"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "album_pictures", force: :cascade do |t|
    t.integer "album_id", limit: 10
    t.string "caption", default: "", null: false
    t.string "picture_file_name"
    t.string "picture_content_type"
    t.integer "picture_file_size"
    t.integer "created_by_id", limit: 10, default: 0, null: false
    t.integer "updated_by_id", limit: 10, default: 0, null: false
    t.integer "position", limit: 10, default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["album_id"], name: "index_album_pictures_on_album_id"
  end

  create_table "albums", force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.string "title", limit: 100
    t.integer "created_by_id", limit: 10, default: 0, null: false
    t.integer "updated_by_id", limit: 10, default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["page_id"], name: "index_albums_on_page_id"
  end

  create_table "application_logs", force: :cascade do |t|
    t.integer "rel_object_id", limit: 10, default: 0
    t.text "object_name"
    t.string "rel_object_type", limit: 50
    t.datetime "created_on", precision: nil, null: false
    t.integer "created_by_id", limit: 10
    t.boolean "is_private", default: false, null: false
    t.boolean "is_silent", default: false, null: false
    t.integer "action_id", limit: 1
    t.integer "page_id", limit: 10
    t.text "previous_name"
    t.integer "modified_page_id", limit: 10
    t.index ["modified_page_id", "created_by_id"], name: "index_application_logs_on_modified_page_id_and_created_by_id"
    t.index ["rel_object_id", "rel_object_type"], name: "index_application_logs_on_rel_object_id_and_rel_object_type"
  end

  create_table "emails", force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.string "subject"
    t.text "body"
    t.integer "created_by_id", limit: 10, default: 0, null: false
    t.integer "updated_by_id", limit: 10, default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "from", default: "", null: false
    t.index ["page_id"], name: "index_emails_on_page_id"
  end

  create_table "favourite_pages", id: false, force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.integer "user_id", limit: 10
  end

  create_table "journals", force: :cascade do |t|
    t.integer "user_id", limit: 10, null: false
    t.string "content", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_journals_on_user_id"
  end

  create_table "list_items", force: :cascade do |t|
    t.integer "list_id", limit: 10
    t.text "content"
    t.datetime "completed_on", precision: nil
    t.integer "completed_by_id", limit: 10
    t.integer "created_by_id", limit: 10
    t.integer "updated_by_id", limit: 10
    t.integer "position", limit: 10, default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["list_id"], name: "index_list_items_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.integer "priority"
    t.string "name", limit: 100
    t.datetime "completed_on", precision: nil
    t.integer "completed_by_id", limit: 10
    t.integer "created_by_id", limit: 10, default: 0, null: false
    t.integer "updated_by_id", limit: 10, default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["page_id"], name: "index_lists_on_page_id"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.string "title", limit: 100
    t.text "content"
    t.integer "created_by_id", limit: 10, default: 0, null: false
    t.integer "updated_by_id", limit: 10, default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "show_date", default: false, null: false
    t.index ["page_id"], name: "index_notes_on_page_id"
  end

  create_table "page_slots", force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.integer "rel_object_id", limit: 10, default: 0, null: false
    t.string "rel_object_type", limit: 30
    t.integer "position", limit: 10, default: 0, null: false
    t.index ["page_id"], name: "index_page_slots_on_page_id"
    t.index ["rel_object_id", "rel_object_type"], name: "index_page_slots_on_rel_object_id_and_rel_object_type"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title", limit: 100
    t.integer "created_by_id", limit: 10
    t.integer "updated_by_id", limit: 10
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "is_public", default: false, null: false
    t.integer "width", default: 400, null: false
    t.string "address", limit: 50
    t.text "settings"
    t.index ["created_by_id"], name: "index_pages_on_created_by_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.text "content"
    t.datetime "at_time", precision: nil
    t.integer "repeat_id", limit: 1, default: 0, null: false
    t.boolean "sent", default: false, null: false
    t.integer "created_by_id", limit: 10
    t.integer "updated_by_id", limit: 10
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["created_by_id"], name: "index_reminders_on_created_by_id"
  end

  create_table "separators", force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.string "title", limit: 100
    t.integer "created_by_id", limit: 10, default: 0, null: false
    t.integer "updated_by_id", limit: 10, default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["page_id"], name: "index_separators_on_page_id"
  end

  create_table "shared_pages", id: false, force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.integer "user_id", limit: 10
  end

  create_table "statuses", force: :cascade do |t|
    t.integer "user_id", limit: 10, null: false
    t.text "content", null: false
    t.datetime "updated_on", precision: nil
    t.index ["user_id"], name: "index_statuses_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.string "name", limit: 30, default: "", null: false
    t.integer "rel_object_id", default: 0, null: false
    t.string "rel_object_type", limit: 50
    t.datetime "created_on", precision: nil
    t.integer "created_by_id", limit: 10, default: 0, null: false
    t.index ["name"], name: "index_tags_on_name"
    t.index ["page_id"], name: "index_tags_on_page_id"
    t.index ["rel_object_id", "rel_object_type"], name: "index_tags_on_rel_object_id_and_rel_object_type"
  end

  create_table "uploaded_files", force: :cascade do |t|
    t.integer "page_id", limit: 10
    t.string "data_file_name"
    t.string "data_content_type"
    t.integer "data_file_size"
    t.integer "created_by_id", limit: 10, default: 0, null: false
    t.integer "updated_by_id", limit: 10, default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "description", default: "", null: false
    t.index ["page_id"], name: "index_uploaded_files_on_page_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", limit: 50, default: "", null: false
    t.string "email", limit: 100
    t.string "token", limit: 40, default: "", null: false
    t.string "salt", limit: 13, default: "", null: false
    t.string "twister", limit: 10, default: "", null: false
    t.string "identity_url"
    t.string "display_name", limit: 50
    t.string "time_zone", null: false
    t.integer "created_by_id", limit: 10
    t.datetime "last_login", precision: nil
    t.datetime "last_visit", precision: nil
    t.datetime "last_activity", precision: nil
    t.boolean "is_admin"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "account_id", limit: 10
    t.integer "home_page_id", limit: 10
    t.string "remember_token", limit: 40
    t.datetime "remember_token_expires_at", precision: nil
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
