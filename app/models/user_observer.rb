class UserObserver < ActiveRecord::Observer
  def after_create(user)
    
    puts "SIGNUP!!!!!!!"
    Notifier.deliver_signup_notification(user)
    puts "SIGNUP!!!!!!!"
  end
end
