#==
# Copyright (C) 2008 James S Urquhart
# Portions Copyright (C) 2009 Qiushi He
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#++

class Tag < ActiveRecord::Base
  include Rails.application.routes.url_helpers

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
    Tag.find(:all, :conditions => {'page_id' => page}, :group => 'name').collect do |tag|
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
