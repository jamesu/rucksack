class ExpandAccounts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :accounts, :host_name, :string, default: "", null: false
    add_column :accounts, :openid_enabled, :boolean, default: false, null: false
    change_column :accounts, :site_name, :string, limit: 255, default: "", null: false
  end

  def self.down
    remove_column :accounts, :host_name
    remove_column :accounts, :openid_enabled
  end
end
