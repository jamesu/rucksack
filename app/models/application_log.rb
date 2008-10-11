=begin
RuckSack
-----------

Copyright (C) 2008 James S Urquhart (jamesu at gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

class ApplicationLog < ActiveRecord::Base
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :rel_object, :polymorphic => true
  belongs_to :page
  
  @@action_lookup = {:add => 0, :edit => 1, :delete => 2, :open => 3, :close => 4, :edit_content => 5}
  @@action_id_lookup = @@action_lookup.invert
  
  def friendly_action
    "action_#{self.action}".to_sym.l
  end
  
  def action
  	@@action_id_lookup[self.action_id]
  end
  
  def action=(val)
  	self.action_id = @@action_lookup[val.to_sym]
  end
  
  def is_today?
    return (self.created_on.to_date >= Date.today and self.created_on.to_date < Date.today+1)
  end
  
  def is_yesterday?
    return (self.created_on.to_date >= Date.today-1 and self.created_on.to_date < Date.today)
  end
     
  def self.new_log(obj, user, action, private=false)
      #logger.warn("ACTION #{obj} by #{user.display_name}(#{user.to_s}) on #{obj.object_name}")
      return if user.nil?
      
      # Lets go...
      @log = ApplicationLog.new(:action => action,
                                :object_name => obj.object_name,
                                :previous_name => obj.respond_to?(:previous_name) ? obj.previous_name : nil,
                                :created_by => user,
                                :is_private => private,
                                :is_silent => false)
      
      if action == :delete
        @log.page = obj.page
        @log.rel_object_id = user
        @log.rel_object_type = obj.class.to_s
        
        # Silence all related logs
        if obj.class == Page
          ApplicationLog.update_all({'is_silent' => true}, {'page_id' => obj.id})
        else
          ApplicationLog.update_all({'is_silent' => true}, {'rel_object_id' => obj.id, 'rel_object_type' => obj.class})
        end
      else
        @log.page = obj.page
        @log.rel_object = obj
      end
      
      if obj.class == Page
        @log.modified_page_id = obj.id
      else
        @log.modified_page_id = @log.page_id
      end
      
      if not user.nil?
        User.update(user.id, {:last_activity => Time.now.utc})
      end
      
      @log.save
  end
  
  def self.grouped_nicely(user, start_date=nil, end_date=nil)
    # Group by creator, page, and date so we eliminate multiple references to the same page in a single day.
    # Non-page objectes are handled by a CASE.
    # Also, offsetting of the date and concatenating the rel_object's id and type are mostly db-specific,
    # so be sure to explicitly add support for other databases as needed.
    
    if connection.adapter_name == 'SQLite'
      offset_date = "date(created_on, '+#{Time.zone.utc_offset} seconds')"
      rel_group = "(rel_object_type || rel_object_id)"
    else
      offset_date = "date(created_on + INTERVAL #{Time.zone.utc_offset} SECOND)"
      rel_group = "CONCAT(rel_object_type, rel_object_id)"
    end
    
    conditions = ['((modified_page_id IS NULL AND created_by_id = ?) OR modified_page_id IN (?)) AND is_silent = ?', user.id, user.available_page_ids, false]
    
    unless start_date.nil?
      conditions[0] += ' AND created_on >= ?'
      conditions << start_date
    end
    
    unless end_date.nil?
      conditions[0] += ' AND created_on < ?'
      conditions << end_date
    end
    
    find(:all,
         :conditions => conditions,
         :order => 'created_on DESC', 
         :group => "created_by_id, #{offset_date}, CASE #{sanitize_sql({'page_id' => nil})} WHEN 1 THEN #{rel_group} ELSE page_id END")
  end
  
  def self.clear_for_page(page)
    ApplicationLog.destroy_all(['page_id = ? OR (rel_object_type = ? AND rel_object_id = ?)', page.id, 'Page', page.id])
  end
end
