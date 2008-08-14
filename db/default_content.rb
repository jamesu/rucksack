#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

initial_user_name = ENV['RUCKSACK_INITIAL_USER']
initial_user_displayname = ENV['RUCKSACK_INITIAL_DISPLAYNAME']
initial_user_password = ENV['RUCKSACK_INITIAL_PASSWORD']
initial_user_email = ENV['RUCKSACK_INITIAL_EMAIL']

initial_user_name ||= 'admin'
initial_user_displayname ||= 'Administrator'
initial_user_password ||= 'password'
initial_user_email ||= 'better.set.this@localhost'

# Ensure owner user exists
initial_user = nil
owner_user = User.find(:first, :conditions => ['users.is_admin'])
if owner_user.nil?
	puts 'Creating owner user...'
	initial_user = User.new(	:display_name => initial_user_displayname,
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
			puts "\nCouldn't create or reset the owner user!\n"
			return
		else
			initial_user.password = initial_user_password
			initial_user.company_id = owner_company.id
			if not initial_user.save
				puts "\nCouldn't reset the owner user!\n"
				return
			end
		end
	end
end

# Ensure the owner account exists
owner_account = Account.find(:first)

unless owner_account.nil?
    owner_account = Account.new()
    owner_account.owner = owner_account
    owner_account.save
end

if !initial_user.nil?
    owner_account.owner ||= initial_user
    owner_account.save
end

