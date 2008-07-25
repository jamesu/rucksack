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

class ListItem < ActiveRecord::Base
	include ActionController::UrlWriter
	
	belongs_to :list
	
	belongs_to :completed_by, :class_name => 'User', :foreign_key => 'completed_by_id'
	
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'

	before_create  :process_params
	after_create   :process_create
	before_update  :process_update_params
	after_update   :update_task_list
	before_destroy :process_destroy
	 
	def process_params
	  write_attribute("completed_on", nil)
	  write_attribute("position", self.task_list.project_tasks.length)
	end
	
	def process_create
	  self.task_list.ensure_completed(!self.completed_on.nil?, self.created_by)
	  ApplicationLog.new_log(self, self.created_by, :add)
	end
	
	def process_update_params
	  if @update_completed.nil?
		write_attribute("updated_on", Time.now.utc)
		if @update_is_minor.nil?
			ApplicationLog.new_log(self, self.updated_by)
		end
	  else
		write_attribute("completed_on", @update_completed ? Time.now.utc : nil)
		self.completed_by = @update_completed_user
		ApplicationLog::new_log(self, @update_completed_user, @update_completed ? :close : :open)
	  end
	end
	
	def process_destroy
	  ApplicationLog.new_log(self, self.updated_by, :delete)
	end
	
	def update_task_list
	  if !@update_completed.nil?
		task_list = self.task_list
		
		task_list.ensure_completed(@update_completed, self.completed_by)
		task_list.save!
	  end
	end
	
	def object_name
		self.content
	end
	
	def object_url
		"#{self.task_list.object_url}#openTasksList#{self.task_list_id}_#{self.id}"
	end
	
	def set_completed(value, user=nil)
	 @update_completed = value
	 @update_completed_user = user
	end
	
	def set_position(value, user=nil)
	  @update_is_minor = true
	  self.position = value
	  self.updated_by = user unless user.nil?
	end
	
	def self.can_be_created_by(user, task_list)
	 return (task_list.project.is_active? and user.member_of(task_list.project) and (!(task_list.is_private and !user.member_of_owner?) and task_list.can_be_managed_by(user)))
	end
	
	def can_be_changed_by(user)
	 project = task_list.project
	 
	 return false if !user.member_of(project) or !project.is_active?
	 return true if user.is_admin
	 
	 task_assigned_to = assigned_to
	 return true if ((task_assigned_to == user) or (task_assigned_to == user.company) or task_assigned_to.nil?)
	 
	 # Owner editable for 3 mins
	 return true if (self.created_by_id == user.id and (self.created_on+(60*3)) < Time.now.utc)
	 
	 return task_list.can_be_changed_by(user)
	end
	
	def can_be_deleted_by(user)
	 task_list.can_be_deleted_by(user)
	end
	
	def can_be_seen_by(user)
	 return (can_be_changed_by(user) or task_list.can_be_seen_by(user))
	end
	
	# Accesibility
	
	attr_accessible :content
	
	# Validation
	
	validates_presence_of :content
end
