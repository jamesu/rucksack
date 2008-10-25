class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifier.deliver_signup_notification(user)
  end
end
