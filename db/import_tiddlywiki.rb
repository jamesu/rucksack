#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

tiddlywiki_location = ENV['TIDDLYWIKI_FILE']
if tiddlywiki_location.nil?
	puts "Please specify the location of your Tiddliwki by setting the TIDDLYWIKI_FILE environment variable"
	exit
end

# Load in the tiddlywiki
basecamp_dump_file = File.open(tiddlywiki_location, 'r') do |file|
  xml = REXML::Document.new(file.read)
  puts "Parsed dump file..."
  
  start = xml.elements['html/body/div[@id=\'storeArea\']']
  if start.nil?
    puts "Looks like this isn't a TiddlyWiki!"
    return
  end
  
  owner = User.owner
  
  start.elements.each do |child|  
    unless child.attributes['title'].nil?
      # Must have a tiddler
      title = child.attributes['title']
      modifier = child.attributes['modifier']
      created_on = Date.parse(child.attributes['created'])
      updated_on = child.attributes['modified'].nil? ? nil : Date.parse(child.attributes['modified'])
      tags = child.attributes['tags'].nil? ? [] : child.attributes['tags'].split(' ')
      
      content = child.elements[1]
      unless content.nil?
        # Yes... really!
        content_data = content.text
        puts "#{title} #{updated_on}"
        puts "tags: #{tags}"
        puts "------"
        puts content_data
        puts "######"
        
        page = Page.new(:title =>title, :tags => tags.join(','))
        page.created_by = owner
        page.save!
        page.created_at = created_on
        page.save!
        
        # One note
        note = page.notes.build({:title => title, :content => content_data})
        note.created_by = owner
        note.save!
        note.created_at = created_on
        note.save!
        
        # One slot
        slot = page.new_slot_at(note, 0, false)
      end
    end
  end
  
end

