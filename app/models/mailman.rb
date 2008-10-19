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
      widget_type = /([a-z]*):/.match(email.subject.lower)[1]
    rescue
      return false
    end
    
    # Have a handler?
    if respond_to? "process_#{widget_type}"
      send "process_#{widget_type}", email
    else
      false
    end
  end
  
  # Insert process_widget handlers here
end
