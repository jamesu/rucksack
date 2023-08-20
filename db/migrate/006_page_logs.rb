class PageLogs < ActiveRecord::Migration[4.2]
  def self.up
    add_column    :application_logs, 'page_id', :integer, :limit => 10
    remove_column :application_logs, 'taken_by_id'
  end

  def self.down
    remove_column :application_logs, 'page_id'
    add_column    :application_logs, 'taken_by_id',     :limit => 10
  end
end
