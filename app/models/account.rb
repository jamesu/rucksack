#==
# Copyright (C) 2008-2023 James S Urquhart
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

class Account < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id', optional: true

  has_many :users

  def self.owner(reload=false)
    @@cached_owner = nil if reload
    @@cached_owner ||= Account.first
  end

  #attr_accessible :site_name, :host_name

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

    #attr_accessible "#{tab}_hidden", "#{tab}_hidden?"
  end

  Colours = ['header', 'tab_background', 'tab_text', 'tab_background_hover', 'tab_text_hover', 'page_header', 'page_header_text']

  Colours.each do |key|
    define_method("#{key}_colour") do
      value = self.get_setting("#{key}_colour")
      return value if value != nil && value.length > 0
      return self.send("default_#{key}_colour")
    end

    define_method("#{key}_colour=") do |value|
      self.set_setting("#{key}_colour", value)
    end

    define_method("default_#{key}_colour") do 
      case key
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

  def set_defaults
    Colours.each do |key|
      set_setting("#{key}_colour", self.send("default_#{key}_colour".to_sym))
    end
  end

  def self.setting_fields
    Colours.map{ |c| "#{c}_colour".to_sym }
  end

  def settings_hash
    if self.settings == nil || self.settings.length <= 0
      return Hash.new
    else
      return YAML.load(self.settings)
    end
  end
end
