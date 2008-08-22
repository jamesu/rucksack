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
                                :created_by => user,
                                :is_private => private)
      
      if action == :delete
        @log.page = obj.class == Page ? nil : obj.page
        @log.rel_object_id = user
        @log.rel_object_type = obj.class.to_s
      else
        @log.page = obj.page
        @log.rel_object = obj
      end
      
      if not user.nil?
        user.last_activity = Time.now.utc
        user.save
      end
      
      @log.save
  end
end
