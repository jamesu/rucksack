class Separator < ActiveRecord::Migration[4.2]
  def self.up
    create_table :separators do |t|
        t.integer  "page_id", limit: 10
        t.string   "title",            limit: 100
        
        t.integer  "created_by_id",   limit: 10,  default: 0,     null: false
        t.integer  "updated_by_id",   limit: 10,  default: 0,     null: false
        
        t.timestamps
    end
  end

  def self.down
    drop_table :separators
  end
end
