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

class List < ActiveRecord::Base
	include ActionController::UrlWriter
	
	belongs_to :page
	has_one :page_slot, :as => :rel_object
	
	belongs_to :completed_by, :class_name => 'User', :foreign_key => 'completed_by_id'
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
	
	has_many :list_items, :dependent => :destroy
	
	before_create  :process_params
	after_create   :process_create
	before_update  :process_update_params
	before_destroy :process_destroy
	
	def process_params
	  write_attribute("completed_on", nil)
	end
	
	def process_create
	  ApplicationLog.new_log(self, self.created_by, :add)
	end
	
	def process_update_params
	  return if !@ensured_complete.nil?
	  ApplicationLog.new_log(self, self.updated_by, :edit)
	end
	
	def process_destroy
	  ApplicationLog.new_log(self, self.updated_by, :delete)
	end
	
	def ensure_completed(task_completed, completed_by)
	  # If the task isn't complete, and we don't think we are
	  # complete either, exit (vice versa)
	  @ensured_complete = true
	  return if self.is_completed? == task_completed
	  
	  # Ok now lets check if we are *really* complete
	  if self.finished_all_items?
	   write_attribute("completed_on", Time.now.utc)
	   self.completed_by = completed_by
	  else
	   write_attribute("completed_on", nil)
	  end
	  
	  ApplicationLog::new_log(self, completed_by, task_completed ? :close : :open)
	end
	
	def object_name
		self.name
	end
	
	def object_url
		url_for :only_path => true, :controller => 'task', :action => 'view_list', :id => self.id, :active_project => self.project_id
	end
	
	def is_completed?
	 return self.completed_on != nil
	end
	
	def open_items
	 self.list_items.reject do |item| not item.completed_on.nil? end
	end
	
	def completed_items
	 self.list_items.reject do |item| item.completed_on.nil? end
	end
	
	def last_edited_by_owner?
	 return (self.created_by.member_of_owner? or (!self.updated_by.nil? and self.updated_by.member_of_owner?))
	end

	def self.can_be_created_by(user, project)
	  project.is_active? and user.has_permission(project, :can_manage_tasks)
	end
	
	def can_be_managed_by(user)
	  project.is_active? and user.has_permission(project, :can_manage_tasks)
	end
	
	def can_be_changed_by(user)
	 return true if user.is_admin
	 
	 return (!(self.is_private and !user.member_of_owner?) and user.id == created_by.id)
	end
	
	def can_be_deleted_by(user)
	 project.is_active? and user.member_of(project) and user.is_admin
	end
	
	def can_be_seen_by(user)
	 return (user.member_of(self.project) and !(self.is_private and !user.member_of_owner?))
	end
	
	def finished_all_tasks?
	 completed_count = 0
	 
	 self.project_tasks.each do |task|
	   completed_count += 1 unless task.completed_on.nil?
	 end
	 
	 return (completed_count > 0 and completed_count == self.project_tasks.length)
	end
    
    def view_partial
        "lists/show"
    end
    
    def self.form_partial
        nil
    end
	
	def self.priv_scope(include_private)
	  yield
	end
	
	def self.select_list(project)
	   List.find(:all, :select => 'id, name').collect do |list|
	      [list.name, list.id]
	   end
	end
	
	# Accesibility
	
	attr_accessible :name
	
	# Validation
	
	validates_presence_of :name
end
