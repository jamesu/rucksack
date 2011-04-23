#==
# Copyright (C) 2008 James S Urquhart
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

class ApplicationLog < ActiveRecord::Base
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :rel_object, :polymorphic => true
  belongs_to :page

  @@action_lookup = {:add => 0, :edit => 1, :delete => 2, :open => 3, :close => 4, :rename => 5}
  @@action_id_lookup = @@action_lookup.invert

  def friendly_action
    t "action_#{self.action}"
  end

  def action
    @@action_id_lookup[self.action_id]
  end

  def action=(val)
    self.action_id = @@action_lookup[val.to_sym]
  end

  def is_today?
    return (self.created_on.to_date >= Date.today and self.created_on.to_date < Date.today+1)
  end

  def is_yesterday?
    return (self.created_on.to_date >= Date.today-1 and self.created_on.to_date < Date.today)
  end

  def self.new_log(obj, user, action, private=false)
    #logger.warn("ACTION #{obj} by #{user.display_name}(#{user.to_s}) on #{obj.object_name}")
    return if user.nil?

    # Lets go...
    @log = ApplicationLog.new(:action => action,
    :object_name => obj.object_name,
    :previous_name => obj.respond_to?(:previous_name) ? obj.previous_name : nil,
    :created_by => user,
    :is_private => private,
    :is_silent => false)

    if action == :delete
      @log.page = obj.page
      @log.rel_object_id = user
      @log.rel_object_type = obj.class.to_s

      # Silence all related logs
      if obj.class == Page
        ApplicationLog.update_all({'is_silent' => true}, {'page_id' => obj.id})
      else
        ApplicationLog.update_all({'is_silent' => true}, {'rel_object_id' => obj.id, 'rel_object_type' => obj.class.to_s})
      end
    else
      @log.page = obj.page
      @log.rel_object = obj
    end

    if obj.class == Page
      @log.modified_page_id = obj.id
    else
      @log.modified_page_id = @log.page_id
    end

    if not user.nil?
      User.update(user.id, {:last_activity => Time.now.utc})
    end

    @log.save
  end

  def self.grouped_nicely(user, start_date=nil, end_date=nil)
    # Group by creator, page, and date so we eliminate multiple references to the same page in a single day.

    conditions = ['((modified_page_id IS NULL AND created_by_id = ?) OR modified_page_id IN (?)) AND is_silent = ?', user.id, user.available_page_ids, false]

    unless start_date.nil?
      conditions[0] += ' AND created_on >= ?'
      conditions << start_date
    end

    unless end_date.nil?
      conditions[0] += ' AND created_on < ?'
      conditions << end_date
    end

    found_records = {}

    # :group => "created_by_id, #{offset_date}, CASE #{sanitize_sql({'page_id' => nil})} WHEN 1 THEN #{rel_group} ELSE page_id END"
    find(:all,
    :conditions => conditions,
    :order => 'created_on ASC').reject do |item|

      obj_key = item.page_id.nil? ? "#{item.rel_object_type}.#{item.rel_object_id}" : item.page_id
      group_key = "#{item.created_by_id}-#{item.created_on.to_date}-#{obj_key}"

      if found_records.has_key? group_key
        true
      else
        found_records[group_key] = item
        false
      end
    end.reverse
  end

  def self.clear_for_page(page)
    ApplicationLog.destroy_all(['page_id = ? OR (rel_object_type = ? AND rel_object_id = ?)', page.id, 'Page', page.id])
  end
end
