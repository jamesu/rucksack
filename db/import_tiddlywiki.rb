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

