class ExtendActivity < ActiveRecord::Migration
  def self.up
    add_column :application_logs, 'previous_name', :text, :default => nil
    add_column :application_logs, 'modified_page_id', :integer, :limit => 10, :default => nil
    
    # Set modified_page_id
    ApplicationLog.find(:all).each do |log|
      next if log.rel_object_type != 'Page' and log.page_id.nil?
      log.update_attribute('modified_page_id', log.page_id || log.rel_object_id)
    end
  end

  def self.down
    remove_column :application_logs, 'previous_name'
    remove_column :application_logs, 'modified_page_id'
  end
end
