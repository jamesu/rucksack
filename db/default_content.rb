#!/usr/bin/env ruby
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

require File.expand_path('../../config/environment',  __FILE__)

initial_user_name = ENV['RUCKSACK_USER'] || 'admin'
initial_user_displayname = ENV['RUCKSACK_DISPLAYNAME'] || 'Administrator'
initial_user_password = ENV['RUCKSACK_PASSWORD'] || 'password'
initial_user_email = ENV['RUCKSACK_EMAIL'] || 'better.set.this@localhost'
initial_site_name = ENV['RUCKSACK_SITE_NAME'] || ''
initial_host_name = ENV['RUCKSACK_HOST_NAME'] || 'localhost'

# Ensure owner user exists
initial_user = nil
owner_user = User.find(:first, :conditions => ['users.is_admin'])
if owner_user.nil?
  puts 'Creating owner user...'
  initial_user = User.new(:display_name => initial_user_displayname,
                          :email => initial_user_email)

  initial_user.username = initial_user_name
  initial_user.password = initial_user_password
  initial_user.is_admin = true
  initial_user.time_zone = 'UTC'

  if not initial_user.save
    puts 'User already exists, attempting to reset...'
    # Try resetting the password
    initial_user = User.find(:first, :conditions => ['username = ?', initial_user_name])
    if initial_user.nil?
      raise Exception, "\nCouldn't create or reset the owner user!\n"
    else
      initial_user.password = initial_user_password
      if not initial_user.save
        raise Exception, "\nCouldn't reset the owner user!\n"
      end
    end
  else
    # Make home page
    home_page = Page.new(:title => "Home Page")
    home_page.created_by = initial_user
    home_page.save
    initial_user.update_attribute('home_page', home_page)
  end

  owner_user = initial_user
end

# Ensure the owner account exists
owner_account = Account.find(:first)

if owner_account.nil?
  owner_account = Account.new()
  owner_account.owner = owner_user
  owner_account.host_name = initial_host_name
  owner_account.site_name = initial_site_name
  owner_account.save
end

owner_user.account = owner_account
owner_user.save
