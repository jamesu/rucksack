require 'ostruct'
require 'yaml'

namespace :db do
	namespace :rucksack do
		desc 'Loads the database schema and inserts initial content'
		task :install => :environment do
			puts "\nLoading schema..."
			Rake::Task["db:schema:load"].invoke
			Rake::Task["db:rucksack:load_config_schema"].invoke
			Rake::Task["db:rucksack:install_content"].invoke
		end

		task :install_content => :environment do
			puts "\nLoading initial content..."
			load("db/default_content.rb")
		end
		
		task :reload_config => :environment do
		    puts "\nRe-loading configuration..."
		    Rake::Task["db:rucksack:dump_config"].invoke
		    Rake::Task["db:rucksack:load_config_schema"].invoke
		    Rake::Task["db:rucksack:load_config"].invoke
		    puts "Done."
		end
		
		task :load_config_schema => :environment do
			puts "\nLoading configuration schema..."
			#load("db/default_config.rb")
		end
		
		task :dump_config => :environment do
			puts "Dumping configuration to config/config.yml"
			#config = OpenStruct.new()
			#ConfigOption.dump_config(config)
			#File.open("#{RAILS_ROOT}/config/config.yml", 'w') do |file|
			#	file.puts YAML::dump(config.marshal_dump)
			#end
		end
		
		task :load_config => :environment do
			puts "Loading configuration from config/config.yml"
			#config = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/config.yml"))
			#ConfigOption.load_config(config)
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
