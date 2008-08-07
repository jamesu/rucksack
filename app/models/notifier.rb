class Notifier < ActionMailer::Base

  def reminder(reminder, sent_at = Time.now)
    @subject    = "#{:reminder.l} - #{reminder.content}"
    @recipients = reminder.created_by.email
    @from       = AppConfig.notification_email_address
    @sent_on    = sent_at
    @headers    = {}
	
	@body       = {
		:site_name => AppConfig.site_name,
		:reminder => reminder,
		:user => reminder.created_by,
		:sent_on => sent_at
	}
  end
  

end
