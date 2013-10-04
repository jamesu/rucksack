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
  default :sender => Proc.new { "noreply@#{Account.owner.host_name}" }

  def reminder(reminder, sent_at = Time.now)
    @site_name = real_site_name
    @reminder = reminder
    @user = reminder.created_by
    @sent_on = sent_at

    mail(:to => reminder.created_by.email,
         :date => sent_at,
         :subject => "#{t('reminder')} - #{reminder.content}")
  end

  def page_share_info(user, page)
    @site_name = real_site_name
    @page = page
    @user = page.updated_by
    @url = "http://#{Account.owner.host_name}#{page_path({:id => page.id, :token => user.twisted_token})}"

    mail(:to => user.email,
         :subject => t('user_wants_to_share_page', :user => page.updated_by.display_name, :page => page.title))
  end

  def signup_notification(user)
    @user = user
    @owner = Account.owner
    @url = "http://#{Account.owner.host_name}/login"

    mail(:to => user.email,
         :subject => "#{real_site_name} - #{t('notifier_signup_subject')}")
  end

  def password_reset(user)
    @user = user
    @site_name = real_site_name
    @sent_on = @sent_on
    @url = "http://#{Account.owner.host_name}/users/reset_password/#{user.id}?confirm=#{user.password_reset_key}"

    mail(:to => user.email,
         :subject => "#{real_site_name} - #{t('notifier_password_reset_subject')}")
  end

  protected

  def real_site_name
    if Account.owner.site_name.empty?
      "#{Account.owner.owner.display_name.pluralize} #{t('product_name')}"
    else
      Account.owner.site_name
    end
  end
end
