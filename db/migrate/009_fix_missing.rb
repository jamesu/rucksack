class FixMissing < ActiveRecord::Migration
  def self.up
    add_column :pages, 'is_public', :boolean, :default => false, :null => false
    add_column :accounts, 'site_name', :string, :default => '', :limit => 100, :null => false
  end

  def self.down
    remove_column :pages, 'is_public'
    remove_column :accounts, 'site_name'
  end
end
