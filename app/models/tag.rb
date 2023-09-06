#==
# Copyright (C) 2008-2023 James S Urquhart
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

class Tag < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :page, optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'

  belongs_to :rel_object, :polymorphic => true, touch: false

  #attr_accessible :name, :page_id, :rel_object, :created_by

  def objects
    return Tag.find_objects(self.name)
  end

  def self.find_objects(tag_name, page)
    Tag.where({name: tag_name, page_id: page}).collect do |tag|
      tag.rel_object
    end
  end

  def self.clear_by_object(object)
    Tag.unscoped.where({rel_object_type: object.class.to_s, rel_object_id: object.id}).delete_all()
  end

  def self.set_to_object(object, taglist, force_user=0)
    if !object.new_record?
      self.clear_by_object(object)
    end

    page_id = (object.class == Page || object.class == Journal) ? nil : object.page_id
    set_user = force_user == 0 ? (object.updated_by.nil? ? object.created_by : object.updated_by) : force_user

    puts "TAG STARTING TRANSACTION FOR SOME REASON? NEW RECORD=#{object.new_record?}"
    Tag.transaction do
      taglist.each do |tag_name|
        Tag.create!(:name => tag_name.strip, :page_id => page_id, :rel_object => object, :created_by => set_user)
      end
    end
  end

  def self.list_by_object(object)
    Tag.where({rel_object_type: object.class.to_s, rel_object_id: object.id}).collect do |tag|
      tag.name
    end
  end

  def self.list_in_page(page)
    Tag.where({page_id: page}).group('name').collect do |tag|
      tag.name
    end
  end

  def self.count_by(tag_name, page)
    tag_conditions = is_public ? 
    {project_id: project.id, is_private: false, tag: tag_name} :
    {project_id: project.id, tag: tag_name}

    Tag.where({name: tag_name, page_id: page}).count
  end

  def self.find_object_join(model)
    "INNER JOIN tags ON tags.rel_object_type = '#{model.to_s}' AND tags.rel_object_id = #{model.table_name}.id"
  end

  def self.find_page_join
    'INNER JOIN tags ON tags.page_id = pages.id'
  end
end
