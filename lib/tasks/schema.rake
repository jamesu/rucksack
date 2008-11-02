require 'ostruct'
require 'yaml'

namespace :db do
	namespace :rucksack do
		desc 'Loads the database schema and inserts initial content'
		task :install => :environment do
			puts "\nLoading schema..."
			Rake::Task["db:schema:load"].invoke
			Rake::Task["db:rucksack:install_content"].invoke
		end

		task :install_content => :environment do
			puts "\nLoading initial content..."
			load("db/default_content.rb")
		end

		task :import_tiddlywiki => :environment do
			puts "\Inmporting TiddlyWiki..."
			load("db/import_tiddlywiki.rb")
		end
		
		# Courtesy of Retrospectiva, Copyright (C) 2006 Dimitrij Denissenko
		desc 'Converts mysql tables to use myisam engine.'
		task :mysql_convert_to_myisam => :environment do
			ActiveRecord::Base.establish_connection
			if ActiveRecord::Base.connection.adapter_name == 'MySQL'
				puts "\n===== Converting to MyISAM"
				ActiveRecord::Base.connection.tables.each do |table_name|
					puts "----- Converting to #{table_name}"
					ActiveRecord::Base.connection.execute("ALTER TABLE `#{table_name}` ENGINE = MYISAM")
				end
				puts "===== Finished\n"
			else
				puts "\nYou are not using a MySQL database!\n"
			end
		end
	end
end
