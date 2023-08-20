class EmailExtras < ActiveRecord::Migration[4.2]
  def self.up
    add_column :emails, 'from', :string, :null => false, :default => ''
  end

  def self.down
    remove_column :emails, 'from'
  end
end
