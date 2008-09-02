=begin
RuckSack
-----------
Copyright (C) 2007 - 2008 James S Urquhart (jamesu at gmail.com)This program is free software; you can redistribute it and/ormodify it under the terms of the GNU General Public Licenseas published by the Free Software Foundation; either version 2of the License, or (at your option) any later version.This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with this program; if not, write to the Free SoftwareFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

class Tag < ActiveRecord::Base
	include ActionController::UrlWriter
	
	belongs_to :page
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	
	belongs_to :rel_object, :polymorphic => true
	
	def objects
		return Tag.find_objects(self.name)
	end
	
	def self.find_objects(tag_name, page)
		Tag.find(:all, :conditions => {'name' => tag_name, 'page_id' => page}).collect do |tag|
			tag.rel_object
		end
	end
	
	def self.clear_by_object(object)
		Tag.delete_all({'rel_object_type' => object.class.to_s, 'rel_object_id' => object.id})
	end
	
	def self.set_to_object(object, taglist, force_user=0)
		self.clear_by_object(object)
		
		page_id = (object.class == Page) ? nil : object.page_id
		set_user = force_user == 0 ? (object.updated_by.nil? ? object.created_by : object.updated_by) : force_user
		
		Tag.transaction do
		  taglist.each do |tag_name|
			  Tag.create(:name => tag_name.strip, :page_id => page_id, :rel_object => object, :created_by => set_user)
		  end
		end
	end
	
	def self.list_by_object(object)
		Tag.find(:all, :conditions => {'rel_object_type' => object.class.to_s, 'rel_object_id' => object.id}).collect do |tag|
			tag.name
		end
	end
	
	def self.list_in_page(page)
		Tag.find(:all, :conditions => {'page_id' => page}).collect do |tag|
			tag.name
		end
	end
	
	def self.count_by(tag_name, page)
		tag_conditions = is_public ? 
		                 ["project_id = ? AND is_private = ? AND tag = ?", project.id, false, tag_name] :
		                 ["project_id = ? AND tag = ?", project.id, tag_name]
		
		Tag.find(:all, :conditions => {'name' => tag_name, 'page_id' => page}, :select => 'id').length
	end
	
	def self.find_object_join(model)
	  "INNER JOIN tags ON tags.rel_object_type = '#{model.to_s}' AND tags.rel_object_id = #{model.table_name}.id"
	end
	
	def self.find_page_join
	  'INNER JOIN tags ON tags.page_id = pages.id'
	end
end
