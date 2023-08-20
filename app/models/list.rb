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

class List < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :page
  has_one :page_slot, as: :rel_object

  has_many :application_logs, as: :rel_object, dependent: :nullify

  belongs_to :completed_by, class_name: 'User', foreign_key: 'completed_by_id', optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', optional: true
  belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by_id', optional: true

  has_many :list_items, dependent: :destroy

  #before_create  :process_params
  after_create   :process_create
  before_update  :process_update_params
  before_destroy :process_destroy

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
    self.list_items.sorted_list.reject do |item| item.is_completed? end
  end

  def completed_items
    self.list_items.sorted_list.reject { |item| !item.is_completed? }
  end

  def last_edited_by_owner?
    return (self.created_by.member_of_owner? or (!self.updated_by.nil? and self.updated_by.member_of_owner?))
  end

  def duplicate(new_page)
    new_list = self.dup
    new_list.created_by = new_page.created_by
    new_list.page = new_page
    new_list.save!

    new_list.list_items = self.list_items.collect do |item|
      new_item = item.clone
      new_item.created_by = new_list.created_by
      new_item.completed_by = item.completed_by
      new_item
    end

    new_list
  end

  # Common permissions

  def self.can_be_created_by(user, page)
    page.can_add_widget(user, List)
  end

  def can_be_edited_by(user)
    self.page.can_be_edited_by(user)
  end

  def can_be_deleted_by(user)
    self.page.can_be_edited_by(user)
  end

  def can_be_seen_by(user)
    self.page.can_be_seen_by(user)
  end

  # Specific permissions

  def can_be_completed_by(user)
    self.can_be_edited_by(user)
  end

  def item_can_be_added_by(user)
    self.can_be_edited_by(user)
  end

  # Useful

  def finished_all_items?
    completed_count = 0

    self.list_items.each do |task|
      completed_count += 1 unless task.completed_on.nil?
    end

    return (completed_count > 0 and completed_count == self.list_items.length)
  end

  def view_partial
    "lists/show"
  end

  def self.form_partial
    nil
  end

  def self.select_list(project)
    List.find(:all, :select => 'id, name').collect do |list|
      [list.name, list.id]
    end
  end

  # Accesibility

  #attr_accessible :name

  # Validation

  validates_presence_of :name
end
