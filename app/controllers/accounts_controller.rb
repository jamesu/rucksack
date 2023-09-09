#==
# Copyright (C) 2008-2023 James S Urquhart
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

class AccountsController < ApplicationController
  layout 'pages'

  # GET /settings
  # GET /settings.xml
  def show
    @account = Account.owner

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @account }
    end
  end
  
  # PUT /settings
  # PUT /settings.xml
  def update
    @account = Account.owner

    respond_to do |format|
      if @account.update(account_params)
        flash[:notice] = t('settings_updated')
        format.html { redirect_back_or_default(action: 'show') }
        format.xml  { head :ok }
      else
        format.html { render action: "show" }
        format.xml  { render xml: @account.errors, status: :unprocessable_entity }
      end
    end
  end

protected

  def account_params
    params[:account].nil? ? {} : params[:account].permit(:site_name, :host_name, *Account.setting_fields)
  end

  def authorized?(action = action_name, resource = nil)
    logged_in? and @logged_user.owner_of_owner?
  end

end
