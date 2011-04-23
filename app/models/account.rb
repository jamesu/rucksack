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

class Account < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'

  has_many :users

  def self.owner(reload=false)
    @@cached_owner = nil if reload
    @@cached_owner ||= Account.find(:first)
  end

  attr_accessible :site_name, :host_name, :openid_enabled

  Tabs = ['overview', 'pages', 'reminders', 'journal']

  Tabs.each do |tab|
    define_method("#{tab}_hidden?") do
      value = self.get_setting("#{tab}_hidden")
      return value == '1' || value == 1 || value == true || value == 'true'
    end

    define_method("#{tab}_hidden") do
      return self.get_setting("#{tab}_hidden")
    end

    define_method("#{tab}_hidden=") do |value|
      self.set_setting("#{tab}_hidden", value)
    end

    attr_accessible "#{tab}_hidden", "#{tab}_hidden?"
  end

  Colours = ['header', 'tab_background', 'tab_text', 'tab_background_hover', 'tab_text_hover', 'page_header', 'page_header_text']

  Colours.each do |colour|
    define_method("#{colour}_colour") do
      value = self.get_setting("#{colour}_colour")
      return value if value != nil && value.length > 0
      return self.send("default_#{colour}_colour")
    end

    define_method("#{colour}_colour=") do |value|
      self.set_setting("#{colour}_colour", value)
    end

    define_method("default_#{colour}_colour") do 
      case colour
      when "header"
        "#007700"
      when "tab_background"
        "#006600"
      when "tab_text"
        "#ffffff"
      when "page_header"
        "#e0eedf"
      when "page_header_text"
        "#333333"
      else
        ""
      end
    end

    attr_accessible "#{colour}_colour"
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
