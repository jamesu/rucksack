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

class Mailman < ActionMailer::Base
  @@content_types = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg']
  def is_image?(file)
    @@content_types.include?(file.content_type)
  end

  def receive(email)
    page = Page.find :first, :conditions => {'address' => email.to.first.split('@')[0]}
    return if page.nil?

    # Find the relevant user. Untrusted users set to anonymous for fwd handler
    responsible_user = User.find(:first, :conditions => {'email' => email.from})
    if responsible_user.nil?
      responsible_user = page.created_by
      responsible_user.is_anonymous = true
    end

    # Handle email and default case
    unless handle_widgets page, email, responsible_user
      page_email = page.emails.build(
      :from => email.from[0],
      :subject => email.subject,
      :body => email.body
      )

      page_email.created_by = responsible_user

      if page_email.save
        # Plonk at top of the page
        page.new_slot_at(page_email, nil, true)
      end
    end

    if email.has_attachments?
      # Add attachment widgets
      shared_album = nil
      email.attachments.reverse.each do |attachment|
        if self.is_image?(attachment)
          # Make shared_album
          if shared_album.nil?
            shared_album = page.albums.build(:title => email.subject)
            shared_album.created_by = responsible_user

            if shared_album.save
              page.new_slot_at(shared_album, nil, true)
            else
              next
            end
          end

          # Add new album picture
          picture = shared_album.pictures.build(:picture => attachment)
          picture.created_by = responsible_user
          picture.album = shared_album
          picture.save
        else
          uploaded_file = page.uploaded_files.build(
          :data => attachment
          )

          uploaded_file.created_by = responsible_user

          if uploaded_file.save
            # Plonk at top of the page
            page.new_slot_at(uploaded_file, nil, true)
          end
        end
      end
    end
  end

  def handle_widgets(page, email, responsible_user)
    # Extract "widget_type:"
    begin
      matches = /([A-Za-z]*):(.*)/.match(email.subject)
      unless matches.nil?
        widget_type = matches[1].downcase
        widget_name = matches[2].strip
      else
        widget_type = matches[0].split(' ')[0]
        widget_name = nil
      end
    rescue
      return false
    end

    # Have a handler?
    if respond_to? "process_#{widget_type}"
      send "process_#{widget_type}", widget_name, page, email, responsible_user
    else
      false
    end
  end

  # Insert process_widget handlers here
  # (alternatively extend Mailman)

  def process_note(name, page, email, responsible_user)
    page_note = page.notes.build(
    :title => name,
    :content => email.body,
    :show_date => true)

    page_note.created_by = responsible_user

    if page_note.save
      # Plonk at top of the page
      page.new_slot_at(page_note, nil, true)
      true
    else
      false
    end
  end

  def process_fwd(name, page, email, responsible_user)
    real_from = nil
    unless responsible_user.is_anonymous?
      real_from = email.body.scan(/^From: .*<(.*)>/)[0]
      real_from = real_from[0] unless real_from.nil?
    end
    real_from ||= email.from[0]

    page_email = page.emails.build(
    :from => real_from,
    :subject => name,
    :body => email.body
    )

    page_email.created_by = responsible_user

    if page_email.save
      # Plonk at top of the page
      page.new_slot_at(page_email, nil, true)
      true
    else
      false
    end
  end

  def process_list(name, page, email, responsible_user)
    page_list = page.lists.build(
    :name => name.nil? ? t('list') : name)

    page_list.created_by = responsible_user

    if page_list.save
      # Plonk at top of the page
      page.new_slot_at(page_list, nil, true)

      # Add list items
      email.body.scan(/\* (.*)/).each do |item|
        list_item = page_list.list_items.build(:content => item.to_s)
        list_item.created_by = responsible_user
        list_item.save
      end

      true
    else
      false
    end
  end

end
