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
	
	has_many :page_shares
	has_many :users, :through=> :page_shares
	has_many :slots, :class_name => 'PageSlot', :order => 'position ASC'
	
	has_many :lists
	has_many :notes
	
	before_create  :process_params
	after_create   :process_create
	before_update  :process_update_params
	before_destroy :process_destroy
	
	def self.widgets
	   [List, Note]
	end
	 
	def process_params
	end
	
	def process_create
	  ApplicationLog.new_log(self, self.created_by, :add)
	end
	
	def process_update_params
	end
	
	def process_destroy
	  ActiveRecord::Base.connection.execute("DELETE FROM page_shares WHERE page_id = #{self.id}")
	  ApplicationLog.new_log(self, self.updated_by, :delete, true)
	end
	
	def object_name
		self.title
	end
	
	def object_url
		url_for :only_path => true, :controller => 'page', :action => 'index', :id => self.id
	end
	
	def is_shared?
	   false
	end
		
	# Core Permissions
	
	def self.can_be_created_by(user)
	 return (user.member_of_owner? and user.is_admin)
	end
	
	def can_be_edited_by(user)
	 return (user.member_of_owner? and user.is_admin)
	end
	
	def can_be_deleted_by(user)
	 return (user.member_of_owner? and user.is_admin)
	end
	
	def can_be_seen_by(user)
	 return (self.has_member(user) or (user.member_of_owner? and user.is_admin))
	end
	
	# Specific Permissions
	
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
