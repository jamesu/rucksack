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

class Page < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'

  has_many :slots, -> { order('position ASC') }, :class_name => 'PageSlot', :dependent => :destroy
  has_many :linked_tags, :class_name => 'Tag', :as => :rel_object, :dependent => :destroy

  has_and_belongs_to_many :shared_users, :class_name => 'User', :join_table => 'shared_pages'
  has_and_belongs_to_many :favourite_users, :class_name => 'User', :join_table => 'favourite_pages'

  has_many :lists, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :separators, :dependent => :destroy
  has_many :emails, :dependent => :destroy
  has_many :uploaded_files, :dependent => :destroy
  has_many :albums, :dependent => :destroy

  before_create  :process_params
  after_create   :process_create
  after_update   :process_update_params
  before_destroy :process_destroy
  after_destroy  :process_after_destroy

  def update_tags
    return if @update_tags.nil?
    Tag.clear_by_object(self)
    Tag.set_to_object(self, @update_tags)
  end

  # Updates guest users (identified by email address)
  def update_shared
    return if @update_shared.nil?

    users = @update_shared.split($/).collect do |ln|
      email = ln.strip
      if !email.empty?
        user = User.find(:first, :conditions => {'email' => email})

        if user.nil?
          # Make the user
          User.make_shared(email, page)
        else
          user
        end
      else
        nil
      end
    end.compact

    updated = false
    new_users = []
    self.shared_users.each do |user|
      if !user.member_of_owner? and !users.include?(user)
        # Don't include, make sure user is deleted if neccesary
        user.remove_shared
        updated = true
      else
        # Add this user
        new_users << user
        users.delete(user)
      end
    end

    # Add remaining users
    users.each { |user| 
      new_users << user
      updated = true
      user.send_page_share_info(self) unless user.member_of_owner? 
    }

    self.shared_users = new_users.uniq if updated
  end

  def self.widgets
    [List, Note, Separator, UploadedFile, Album]
  end

  def process_params
    generate_address
  end

  def process_create
    ApplicationLog.new_log(self, self.created_by, :add)
    update_tags
  end

  def process_update_params
    ApplicationLog.new_log(self, self.created_by, @previous_name.nil? ? :edit : :rename)
    update_tags
    update_shared
  end

  def process_destroy
    ApplicationLog.new_log(self, self.updated_by, :delete)
  end

  def process_after_destroy
    ApplicationLog.clear_for_page(self) # Clear delete logs (amongst other things)
  end

  def page
    nil
  end

  def page_id
    self.id
  end

  def tags
    return tags_list.join(',')
  end

  def tags_list
    @update_tags.nil? ? Tag.list_by_object(self) : @update_tags
  end

  def tags_with_spaces
    return Tag.list_by_object(self).join(' ')
  end

  def tags=(val)
    @update_tags = (val || '').split(',')
  end

  def object_name
    self.title
  end

  def title=(value)
    @previous_name = self.title
    write_attribute('title', value)
  end

  def previous_name
    @previous_name
  end

  def object_url
    page_url(:id => self.id, :only_path => true)
  end

  def is_shared?
    !shared_users.empty? or is_public
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
    return false if self.created_by.home_page_id == self.id
    return (user.is_admin or user.id == self.created_by_id)
  end

  def can_be_seen_by(user)
    return true if self.is_public
    return (user.is_admin or user.id == self.created_by_id or shared_user_ids.include?(user.id))
  end

  # Specific Permissions
  def can_be_shared_by(user)
    return (user.is_admin or user.id == self.created_by_id)
  end

  def can_be_favourited_by(user)
    self.can_be_seen_by(user) and user.can_add_favourite(user)
  end

  def can_be_duplicated_by(user)
    self.can_be_edited_by(user) and Page.can_be_created_by(user)
  end

  def can_add_widget(user, widget)
    return self.can_be_edited_by(user)
  end

  def can_reset_email(user)
    return (user.is_admin or user.id == self.created_by_id or (user.member_of_owner? and shared_user_ids.include?(user.id)))
  end

  # Helpers

  def new_slot_at(insert_widget, insert_id, insert_before)
    PageSlot.transaction do

      # Calculate correct position
      if !insert_id.nil? and insert_id != 0
        old_slot = PageSlot.find(insert_id)
        insert_pos = insert_before ? old_slot.position : old_slot.position+1
      else
        if self.slots.empty?
          insert_pos = 0
        else
          insert_pos = insert_before ? self.slots[0].position : 
          self.slots[self.slots.length-1].position+1
        end
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

      new_page = self.dup
      new_page.title = I18n.t('copy_of_page', :title => self.title)
      new_page.created_by = new_owner
      new_page.address = 'random'
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

  def address=(value)
    new_value = value == 'random' ? generate_address : value
    write_attribute('address', new_value)
  end

  def shared_emails
    @update_shared || self.shared_users.where({'account_id' => nil}).map{ |user| user.email }.join("\n")
  end

  def shared_emails=(value)
    @update_shared = value
  end

  def generate_address
    # Grab a few random things...
    tnow = Time.now()
    sec = tnow.tv_usec
    usec = tnow.tv_usec % 0x100000
    rval = rand()
    roffs = rand(25)
    self.address = Digest::SHA1.hexdigest(sprintf("%s%08x%05x%.8f", rand(32767), sec, usec, rval))[roffs..roffs+12]
  end

  def self.select_list
    Page.find(:all).collect do |page|
      [page.name, page.id]
    end
  end

  # Serialization
  alias_method :ar_to_xml, :to_xml

  def to_xml(options = {}, &block)
    default_options = {
      :methods => [ :tags ]
    }

    default_options[:include] = { :slots => {:only => [:id, :position, :width, :rel_object_type, :rel_object_id]}  } unless options[:in_list]
    self.ar_to_xml(options.merge(default_options), &block)
  end

  # Accesibility

  attr_accessible :title, :tags, :width

  # Validation

  validates_presence_of :title
  validates_uniqueness_of :address

  def sidebar_order
    value = self.get_setting("sidebar_order")
    return -1 if value == nil
    return value
  end

  def sidebar_order=(value)
    self.set_setting("sidebar_order", value)
  end

  # Settings Serialization
  def get_setting(key)
    (self.settings_hash)[key]
  end

  def set_setting(key, value)
    hash = self.settings_hash
    hash[key] = value
    self.settings = YAML.dump(hash)
  end

  def settings_hash
    if self.settings == nil || self.settings.length <= 0
      return Hash.new
    else
      return YAML.load(self.settings)
    end
  end
end
