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

class UploadedFile < ActiveRecord::Base
  belongs_to :page
  has_one :page_slot, :as => :rel_object

  has_many :application_logs, :as => :rel_object, :dependent => :nullify

  has_attached_file :data

  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'

  after_create   :process_create
  before_update  :process_update_params
  before_destroy :process_destroy

  def process_create
    ApplicationLog.new_log(self, self.created_by, :add)
  end

  def process_update_params
    ApplicationLog.new_log(self, self.updated_by, :edit)
  end

  def process_destroy
    ApplicationLog.new_log(self, self.updated_by, :delete)
  end

  def object_name
    self.data.original_filename
  end

  def view_partial
    "uploaded_files/show"
  end

  def self.form_partial
    "uploaded_files/form"
  end

  def last_modified
    self.updated_at || self.created_at
  end

  def duplicate(new_page)
    new_file = self.clone
    new_file.created_by = new_page.created_by
    new_file.page = new_page

    new_file.save!
    new_file
  end

  # Common permissions

  def self.can_be_created_by(user, page)
    page.can_add_widget(user, UploadedFile)
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

  # Accesibility

  attr_accessible :data, :description

  # Validation

  validates_attachment_presence :data
end
