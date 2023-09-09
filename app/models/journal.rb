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

require 'sanitize'

class Journal < ApplicationRecord
  belongs_to :user
  has_many :linked_tags, class_name: 'Tag', as: :rel_object, dependent: :destroy

  after_create  :update_tags # NOTE: this needs to be after since otherwise we can get stuck in a loop
  before_create :check_entry
  before_update :check_entry_update

  scope :sorted_list, -> { order(created_at: :desc) }

  # Time related

  attr_accessor :quick_update
  
  def start(started_at=nil)
    self.start_date = started_at || Time.now
    self.seconds = nil
  end
  
  # e.g. @project #task 
  #      +1h (1 hour ago) 
  #      1h+ (expected to take 1 hour, from now) 
  #      1h (took one hour)
  TIMEVAL_REGEXP = /[\+\-]?(?:[0-9]+[sSHhMm])+[\+\-]?/
  TIMEVAL_UNIT_REGEXP = /[0-9]+[sSHhMm]/
  TAG_REGEXP = /[#][a-zA-Z0-9\-_]*/
  
  def format_entry(origin_base=nil)
    found_service = nil
    found_project = nil
    time_now = origin_base.nil? ? Time.now : origin_base

    gen = Sanitize.fragment(content)
    tag_list = []

    gen = gen.gsub(TAG_REGEXP) do |tag|
      tag_list << tag
      # Emit tag
      "<span class=\"journalTag\">#{tag}</span>"
    end
    
    found_start = nil
    found_done = nil
    found_limit = nil
    
    # Calculate times from timeVal
    gen = gen.gsub(TIMEVAL_REGEXP) do |timeVal|
      # Parse...
      in_progress = timeVal[-1..-1] == '+'
      delta_inc = timeVal[0..0] == '+'
      delta_dec = timeVal[0..0] == '-'
      units = timeVal.scan(TIMEVAL_UNIT_REGEXP)
      hours, minutes, seconds = 0,0,0

      units.each do |u|
        case u[-1..-1].upcase
        when 'H'
          hours = u[0...-1].to_i
        when 'M'
          minutes = u[0...-1].to_i
        when 'S'
          seconds = u[0...-1].to_i
        end
      end

      delta_s = (hours*60*60) + (minutes*60) + seconds 

      # Determine start
      if delta_inc
        # will be spending x time on it
        found_start = time_now
        found_done = in_progress ? nil : found_start + delta_s
      elsif delta_dec
        # spent x time on it already
        last_ended = time_now
        found_done = in_progress ? nil : last_ended
        found_start = last_ended - delta_s
      else
        # expecting to spend x time on it [not confirmed]
        found_start = time_now
        found_done = nil
        found_limit = delta_s
      end

      "<span class=\"journalTime\">#{timeVal}</span>"
    end
    
    { start_date: found_start, 
      done_date: found_done,
      limit: found_limit,
      origin_time: time_now,
      html: gen,
      tags: tag_list }
  end

  def content_html
    format_entry(self.created_at)[:html]
  end

  def set_tags(tag_list)
    Tag.set_to_object(self, tag_list)
    true
  end

  def created_by
    self.user
  end

  def updated_by
    self.user
  end
  
  def check_entry
    built = format_entry(self.created_at)
    self.original_start = built[:origin_time]
    
    self.start_date = built[:start_date]
    self.done_date = built[:done_date]
    self.seconds_limit = built[:limit]
    
    self.seconds = current_time unless self.done_date.nil?
  end

  def update_tags
    set_tags(format_entry(self.created_at)[:tags])
    true
  end
  
  def check_entry_update
    unless @quick_update
      # Like check_entry, except we maintain start_date
      # We also maintain done_date unless it was specified
      # in the content
      built = format_entry(self.original_start)
      
      unless self.original_start.nil?
        self.start_date = built[:start_date]
        self.done_date ||= built[:done_date]
        self.seconds_limit = built[:limit]
      end
    else
      built = format_entry(self.original_start)
    end
    
    self.seconds = current_time unless self.done_date.nil?
    set_tags(built[:tags])
  end
  
  def stop_timer
    self.done_date = Time.now
    self.seconds = self.done_date - self.start_date
  end
  
  def clone_from(other)
    self.user = other.user
    self.project = other.project
    self.service = other.service
    
    self.start_date = Time.now
    self.done_date = nil
    self.seconds = nil
    self.seconds_limit = other.seconds_limit
  end
  
  def current_time
    if self.done_date.nil?
      # Use start
      Time.now - self.start_date
    else
      # Diff between start and end
      self.done_date - self.start_date
    end
  end

  def done?
    !self.done_date.nil?
  end
  
  def is_overdue?
    return false if seconds_limit.nil?
    
    self.current_time > self.seconds_limit
  end
  
  def date
    self.start_date.to_date
  end
  
  def hours
    (self.seconds || 0) / 60.0 / 60.0
  end
  
  def hours_limit
    (self.seconds_limit || self.seconds || 0) / 60.0 / 60.0
  end

  # Common permissions

  def self.can_be_created_by(user)
    user.member_of_owner?
  end

  def can_be_edited_by(user)
    return (user.is_admin or user.id == self.created_by_id)
  end

  def can_be_deleted_by(user)
    return (user.is_admin or user.id == self.created_by_id)
  end

  def can_be_seen_by(user)
    return (user.is_admin or user.account_id == self.user.account_id)
  end

  # Accesibility

  #attr_accessible :content

  # Validation

  validates_presence_of :content
end
