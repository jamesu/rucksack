class PageSettings < ActiveRecord::Migration[4.2]
    def self.up
        add_column :pages, 'settings', :text
    end

    def self.down
        remove_column :pages, 'settings'
    end
end
