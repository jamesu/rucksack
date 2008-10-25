class Notifier < ActionMailer::Base

  def reminder(reminder, sent_at = Time.now)
    @subject    = "#{:reminder.l} - #{reminder.content}"
    @recipients = reminder.created_by.email
    @from       = AppConfig.notification_email_address
    @sent_on    = sent_at
    @headers    = {}
	
	  @body       = {
		  :site_name => Account.owner.site_name,
		  :reminder => reminder,
		  :user => reminder.created_by,
		  :sent_on => sent_at
	  }
  end
  
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://YOURSITE/activate/#{user.activation_code}"
  
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = AppConfig.notification_email_address
      @subject     = "#{site_name} - "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
