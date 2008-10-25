class LoginRestful < ActiveRecord::Migration
  def self.up
    add_column :users, :remember_token,            :string, :limit => 40
    add_column :users, :remember_token_expires_at, :datetime
    remove_column :users, :avatar_file
  end

  def self.down
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
    add_column :users, :avatar_file, :string, :limit => 44
  end
end
