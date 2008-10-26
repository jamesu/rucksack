class Notifier < ActionMailer::Base

  def reminder(reminder, sent_at = Time.now)
    @subject    = "#{:reminder.l} - #{reminder.content}"
    @recipients = reminder.created_by.email
    @from       = "noreply@#{Account.owner.host_name}"
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
    @subject    += :notifier_signup_subject.l
    
    @body[:owner] = Account.owner
    @body[:url] = "http://#{Account.owner.host_name}/login"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "noreply@#{Account.owner.host_name}"
      @subject     = "#{Account.owner.site_name} - "
      @sent_on     = Time.now
      
      @body[:user] = user
    end
end
