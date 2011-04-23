class Nukeopenid < ActiveRecord::Migration
  def self.up
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
    remove_column :accounts, :openid_enabled
  end

  def self.down
    add_column :accounts, :openid_enabled, :boolean, :default => false, :null => false
    create_table :open_id_authentication_associations do |t|
      t.integer "issued",     :limit => 11
      t.integer "lifetime",   :limit => 11
      t.string  "handle"
      t.string  "assoc_type"
      t.binary  "server_url"
      t.binary  "secret"
    end

    create_table :open_id_authentication_nonces do |t|
      t.integer "timestamp",  :limit => 11,                 :null => false
      t.string  "server_url"
      t.string  "salt",                     :default => "", :null => false
    end
  end
end
