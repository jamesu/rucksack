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

# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  layout 'dialog'

  # render new.rhtml
  def new
    @login_token = params[:token]
    render :action => (@login_token.nil? ? 'new' : 'new_token')
  end
  
  def show
    create
  end

  def create
    logout_keeping_session!
    
    if !params[:token].nil?
      user = User.find_by_email(params[:token_email])
      user = nil if user.nil? or !user.twisted_token_valid?(params[:token])
    else
      user = User.authenticate(params[:login], params[:password])
    end
    
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
      @login_token = params[:token]
      @login_email = params[:token_email]
      render :action => (@login_token.nil? ? 'new' : 'new_token')
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
