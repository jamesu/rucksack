class AccountSettings < ActiveRecord::Migration[4.2]
    def self.up
        add_column :accounts, 'settings', :text
    end

    def self.down
        remove_column :accounts, 'settings'
    end
end
