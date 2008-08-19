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

class Page < ActiveRecord::Base
	include ActionController::UrlWriter
	
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
	
	has_many :slots, :class_name => 'PageSlot', :order => 'position ASC'
	
	has_and_belongs_to_many :shared_users, :class_name => 'User', :join_table => 'shared_pages'
	has_and_belongs_to_many :favourite_users, :class_name => 'User', :join_table => 'favourite_pages'
	
	has_many :lists
	has_many :notes
	has_many :separators
	
	before_create  :process_params
	after_create   :process_create
	before_update  :process_update_params
	before_destroy :process_destroy
	
	def self.widgets
	   [List, Note, Separator]
	end
	 
	def process_params
	end
	
	def process_create
	  ApplicationLog.new_log(self, self.created_by, :add)
	end
	
	def process_update_params
	  ApplicationLog.new_log(self, self.created_by, :edit)
	end
	
	def process_destroy
	  ApplicationLog.new_log(self, self.updated_by, :delete)
	end
	
	def object_name
		self.title
	end
	
	def object_url
		url_for :only_path => true, :controller => 'page', :action => 'index', :id => self.id
	end
	
	def is_shared?
	   !shared_users.empty?
	end
	
	def is_favourite?(user)
	   favourite_user_ids.include?(user.id)
	end
		
	# Core Permissions
	
	def self.can_be_created_by(user)
	 return (user.member_of_owner?)
	end
	
	def can_be_edited_by(user)
	 return (user.is_admin or user.id == self.created_by_id or shared_user_ids.include?(user.id))
	end
	
	def can_be_deleted_by(user)
	 return (user.is_admin or user.id == self.created_by_id)
	end
	
	def can_be_seen_by(user)
	 return (user.is_admin or user.id == self.created_by_id or shared_user_ids.include?(user.id))
	end
	
	# Specific Permissions
	def can_be_shared_by(user)
	   return (user.is_admin or user.id == self.created_by_id)
	end
	
	def can_be_duplicated_by(user)
	   return (self.can_be_edited_by(user) and Page.can_be_created_by(user))
	end
	
	def can_add_widget(user, widget)
	   return self.can_be_edited_by(user)
	end
	
	# Helpers
	
	def new_slot_at(insert_widget, insert_id, insert_before)
	   PageSlot.transaction do
	   
	   # Calculate correct position
	   if insert_id != 0
	       old_slot = PageSlot.find(insert_id)
	       insert_pos = insert_before ? old_slot.position : old_slot.position+1
	   else
	       insert_pos = self.slots.empty? ? 0 : self.slots[self.slots.length-1].position+1
	   end
	   
       # Bump up all other slots
       self.slots.each do |slot|
	       if slot.position >= insert_pos
	           slot.position += 1
	           slot.save
	       end
       end
       
       # Make the new slot, damnit!
       @slot = PageSlot.new(:page => self, :position => insert_pos, :rel_object => insert_widget)
       @slot.save
       
       return @slot
       end      
	end
	
	def duplicate(new_owner)
	   Page.transaction do
	   
	   new_page = self.clone
	   new_page.title = :copy_of_page.l_with_args(:title => self.title)
	   new_page.created_by = new_owner
	   new_page.save!
	   
	   # Duplicate in the slots...
	   new_page.slots = self.slots.collect do |slot|
	       new_slot = slot.clone
	       
	       # The related object
	       new_obj = slot.rel_object.duplicate(new_page)
	       
	       new_slot.rel_object = new_obj
	       new_slot
	   end
	   
	   return new_page
	   end
	end
	
	def self.select_list
	 Page.find(:all).collect do |page|
	   [page.name, page.id]
	 end
	end
	
	# Accesibility
	
	attr_accessible :title
	
	# Validation
	
	validates_presence_of :title
end
