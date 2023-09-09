class PageSharing < ActiveRecord::Migration[4.2]
  def self.up
    create_table :shared_pages, id: false do |t|
      t.integer  "page_id",   limit: 10
      t.integer  "user_id",   limit: 10
    end
    create_table :favourite_pages, id: false do |t|
      t.integer  "page_id",   limit: 10
      t.integer  "user_id",   limit: 10
    end
  end

  def self.down
    drop_table :shared_pages
    drop_table :favourite_pages
  end
end
