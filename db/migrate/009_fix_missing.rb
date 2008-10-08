class FixMissing < ActiveRecord::Migration
  def self.up
    add_column :pages, 'is_public', :boolean, :default => false, :null => false
    add_column :pages, 'width', :integer, :default => 400, :null => false
    add_column :accounts, 'site_name', :string, :default => '', :limit => 100, :null => false
    add_column :notes, 'show_date', :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :pages, 'is_public'
    remove_column :pages, 'width'
    remove_column :accounts, 'site_name'
    remove_column :notes, 'show_date'
  end
end
