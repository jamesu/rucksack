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

class ListItem < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :list
  def page; self.list.page; end
  def page_id; self.list.page_id; end

  has_many :application_logs, as: :rel_object, dependent: :nullify

  belongs_to :completed_by, class_name: 'User', foreign_key: 'completed_by_id', optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', optional: true
  belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by_id', optional: true

  before_create  :process_params
  after_create   :process_create
  before_update  :process_update_params
  after_update   :update_list
  before_destroy :process_destroy

  scope :sorted_list, -> { order('position ASC, completed_on ASC') }

  def process_params
    write_attribute("position", self.list.list_items.length)
  end

  def process_create
    self.list.ensure_completed(!self.completed_on.nil?, self.created_by)
    ApplicationLog.new_log(self, self.created_by, :add)
  end

  def process_update_params
    if @update_completed.nil?
      write_attribute("updated_at", Time.now.utc)
      if @update_is_minor.nil?
        ApplicationLog.new_log(self, self.updated_by, :edit)
      end
    else
      write_attribute("completed_on", @update_completed ? Time.now.utc : nil)
      self.completed_by = @update_completed_user
      ApplicationLog::new_log(self, @update_completed_user, @update_completed ? :close : :open)
    end
  end

  def process_destroy
    #ApplicationLog.new_log(self, self.updated_by, :delete)
  end

  def update_list
    if !@update_completed.nil?
      list = self.list

      list.ensure_completed(@update_completed, self.completed_by)
      list.save!
    end
  end

  def object_name
    self.content
  end

  def object_url
    "#{self.task_list.object_url}#openTasksList#{self.task_list_id}_#{self.id}"
  end

  def is_completed?
    return self.completed_on != nil
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

  # Common permissions

  def self.can_be_created_by(user, in_list)
    in_list.item_can_be_added_by(user)
  end

  def can_be_edited_by(user)
    list.can_be_edited_by(user)
  end

  def can_be_deleted_by(user)
    list.can_be_deleted_by(user)
  end

  def can_be_seen_by(user)
    list.can_be_seen_by(user)
  end

  # Specific permissions
  def can_be_completed_by(user)
    self.can_be_edited_by(user)
  end

  # Accesibility

  #attr_accessible :content

  # Validation

  validates_presence_of :content
end
