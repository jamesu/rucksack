class PageTags < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tags do |t|
      t.integer  "page_id",          limit: 10,   default: nil
      t.string   "name",             limit: 30,   default: "",  null: false
      t.integer  "rel_object_id",                    default: 0,   null: false
      t.string   "rel_object_type",  limit: 50
      t.datetime "created_on"
      t.integer  "created_by_id",    limit: 10,   default: 0,   null: false
    end
  end

  def self.down
    drop_table :tags
  end
end
