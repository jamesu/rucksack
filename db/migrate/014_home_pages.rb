class HomePages < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :home_page_id, :integer, limit: 10
    User.all.each do |user|
      home_page = Page.new(title: "#{user.display_name.pluralize} page")
      home_page.created_by = user
      home_page.save
      user.update_attribute('home_page', home_page)
    end
  end

  def self.down
    remove_column :users, :home_page_id
  end
end
