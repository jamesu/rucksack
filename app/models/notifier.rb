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

class Notifier < ActionMailer::Base

  def reminder(reminder, sent_at = Time.now)
    @subject    = "#{t('reminder')} - #{reminder.content}"
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

  def page_share_info(user, page)
    @subject    = t('user_wants_to_share_page', 
    :user => page.updated_by.display_name, 
    :page => page.title)
    @recipients = user.email
    @from       = "noreply@#{Account.owner.host_name}"
    @sent_on    = Time.now
    @headers    = {}

    @body       = {
      :site_name => Account.owner.site_name,
      :page => page,
      :user => page.updated_by,
      :url => "http://#{Account.owner.host_name}#{page_path({:id => page.id, :token => user.twisted_token})}"
    }
  end

  def signup_notification(user)
    setup_email(user)
    @subject    += t('notifier_signup_subject')

    @body[:owner] = Account.owner
    @body[:url] = "http://#{Account.owner.host_name}/login"
  end

  def password_reset(user)
    setup_email(user)
    @subject    += t('notifier_password_reset_subject')
    @recipients = user.email
    @from       = "noreply@#{Account.owner.host_name}"
    @sent_on    = Time.now
    @headers    = {}

    @body[:site_name] = Account.owner.site_name
    @body[:sent_on] = @sent_on
    @body[:url] = "http://#{Account.owner.host_name}/users/reset_password/#{user.id}?confirm=#{user.password_reset_key}"
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
