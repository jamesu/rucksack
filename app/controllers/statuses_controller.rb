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

class StatusesController < ApplicationController
  layout 'pages'
  
  before_filter :grab_user

  # GET /statuses/1
  # GET /statuses/1.xml
  def show
    user_ids = Account.owner.user_ids - [@user.id]
    
    @status = @user.status
    return error_status(true, :cannot_see_status) unless (@status.can_be_seen_by(@logged_user))
    
    @statuses = Status.find(:all, :conditions => {'user_id' => user_ids})

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => [@status] + @statuses }
    end
  end

  # PUT /statuses/1
  # PUT /statuses/1.xml
  def update
    @status = @user.status || @user.build_status(:content => t('status'))
    return error_status(true, :cannot_edit_status) unless (@status.can_be_edited_by(@logged_user))
    
    @status.attributes = params[:status]

    respond_to do |format|
      if @status.save
        flash[:notice] = 'Status was successfully updated.'
        format.html { redirect_to(journals_url) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end
end
