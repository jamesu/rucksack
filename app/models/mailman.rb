class Mailman < ActionMailer::Base
  
  def receive(email)
    page = Page.find :first, :conditions => {'address' => email.to.first.split('@')[0]}
    return if page.nil?
    
    # Handle email and default case
    unless handle_widgets email
      page_email = page.emails.build(
        :subject => email.subject,
        :body => email.body
      )
      # TBD: Make an anonymous email user?
      page_email.created_by = page.created_by
      
      if page_email.save
        # Plonk at top of the page
        page.new_slot_at(page_email, nil, true)
      end
    end
    
    if email.has_attachments?
      # TODO (need to support file attachments!)
    end
  end
  
  def handle_widgets(email)
    # Extract "widget_type:"
    begin
      matches = /([A-Za-z]*):/.match(email.subject)
      unless matches.nil?
        widget_type = matches[1]
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
      send "process_#{widget_type}", widget_name, page, email
    else
      false
    end
  end
  
  # Insert process_widget handlers here
  # (alternatively extend Mailman)
  
  def process_note(name, page, email)
    page_note = page.notes.build(
      :title => name,
      :content => email.body
      :show_date => true)
    
    page_note.created_by = page.created_by
    
    if page_note.save
      # Plonk at top of the page
      page.new_slot_at(page_note, nil, true)
      true
    else
      false
    end
  end
  
  def process_list(name, page, email)
    page_list = page.lists.build(
      :name => name.nil? ? :list.l : name)
    
    page_list.created_by = page.created_by
    
    if page_list.save
      # Plonk at top of the page
      page.new_slot_at(page_list, nil, true)
      
      # Add list items
      email.body.scan /\* (.*)/).each do |item|
        list_item = page_list.list_items.build(:content => item)
        list_item.created_by = @logged_user
        list_item.save
      end
      
      true
    else
      false
    end
  end
  
end
