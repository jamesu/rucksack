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
  
  filter_parameter_logging :password

  # render new.rhtml
  def new
    @login_token = params[:token]
    @use_openid = params[:use_openid].to_i == 1
    render :action => (@login_token.nil? ? 'new' : 'new_token')
  end
  
  def show
    create
  end

  def create
    logout_keeping_session!
    
    @use_openid = params[:use_openid].to_i == 1
    
    if !params[:token].nil?
      user = User.find_by_email(params[:token_email])
      user = nil if user.nil? or !user.twisted_token_valid?(params[:token])
    elsif using_open_id? || @use_openid
      return create_openid
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
  
  # OpenID handler for create
  def create_openid
    unless Account.owner.openid_enabled
      error_status(true, :invalid_request, {}, false)
      redirect_to :action => 'new'
      return
    end

    authenticate_with_open_id(params[:openid_url]) do |result, identity_url, registration|
      if result.successful?
        log_user = User.openid_login(identity_url)

        if log_user.nil?
          error_status(true, :failed_login_openid_url, {:openid_url => identity_url}, false)
        else
          error_status(false, :success_login_openid_url, {:openid_url => identity_url})
          
          self.current_user = log_user
          new_cookie_flag = (params[:remember_me] == "1")
          handle_remember_cookie! new_cookie_flag
          redirect_back_or_default('/')
          error_status(false, :login_success)
          return
        end

        redirect_to :action => 'new'

      elsif result.unsuccessful?
        if result == :canceled
          error_status(true, :verification_cancelled, {}, false)
        elsif !identity_url.nil?
          error_status(true, :failed_verification_openid_url, {:openid_url => identity_url}, false)
        else
          error_status(true, :verification_failed, {}, false)
        end

        redirect_to :action => 'new'

      else
        error_status(true, :unknown_response_status, {:status => result.message}, false)
        redirect_to :action => 'new'
      end
    end

    # Must have failed
    logger.warn "Failed login for '#{params[:openid_url]}' from #{request.remote_ip} at #{Time.now.utc}"
    @login       = params[:login]
    @remember_me = params[:remember_me]
    @login_token = params[:token]
    @login_email = params[:token_email]
  end
  
  def authorized?(action = action_name, resource = nil)
    true
  end 
end
