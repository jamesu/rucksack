class OpenidSchema < ActiveRecord::Migration[4.2]
  def self.up
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

  def self.down
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
  end
end
