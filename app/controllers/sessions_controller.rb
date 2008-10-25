# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  layout 'dialog'

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      error_status(false, :login_success)
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    error_status(false, :logout_success)
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    error_status(true, :login_failure, {}, false)
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  def authorized?(action = action_name, resource = nil)
    true
  end 
end
