class CreateAccounts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :accounts do |t|
      t.integer 'owner_id', limit: 10, null: false
      t.timestamps
    end
    
    add_column :users, 'account_id', :integer, limit: 10, default: nil
  end

  def self.down
    drop_table :accounts
    remove_column :users, :account_id
  end
end
