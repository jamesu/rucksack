class AddEmails < ActiveRecord::Migration[4.2]
  def self.up
    add_column "pages", "address", :string, limit: 50

    create_table "emails", force: true do |t|
      t.integer  "page_id",       limit: 10
      
      t.string   "subject"
      t.text     "body"
      t.integer  "created_by_id", limit: 10,  default: 0, null: false
      t.integer  "updated_by_id", limit: 10,  default: 0, null: false
      
      t.timestamps
    end
    
    # Generate addresses for all pages
    Page.all.each do |page|
      page.generate_address
      page.save
    end
  end

  def self.down
    remove_column "pages", "address"
    drop_table "emails"
  end
end
