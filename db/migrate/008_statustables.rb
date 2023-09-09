class Statustables < ActiveRecord::Migration[4.2]
  def self.up
    create_table :statuses do |t|
      t.integer  "user_id", limit: 10, null: false
      t.text "content", null: false
      
      t.datetime 'updated_on'
    end
    create_table :journals do |t|
      t.integer  "user_id", limit: 10, null: false
      t.string "content", null: false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :statuses
    drop_table :journals
  end
end
