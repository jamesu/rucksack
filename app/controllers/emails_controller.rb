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

class EmailsController < ApplicationController
  layout nil
  
  before_filter :grab_page
  before_filter :load_email, :except => [:index, :new, :create]
  
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  
  # GET /emails
  # GET /emails.xml
  def index
    @emails = @page.emails.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @emails }
    end
  end

  # GET /emails/1
  # GET /emails/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @email }
    end
  end

  # GET /emails/new
  # GET /emails/new.xml
  def new
    return error_status(true, :cannot_create_email) unless (Email.can_be_created_by(@logged_user, @page))
    
    @email = @page.emails.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email }
    end
  end

  # GET /emails/1/edit
  def edit
    return error_status(true, :cannot_edit_email) unless (@email.can_be_edited_by(@logged_user))

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /emails
  # POST /emails.xml
  def create
    return error_status(true, :cannot_create_email) unless (Email.can_be_created_by(@logged_user, @page))
    
    calculate_position
    
    # Make the darn note
    @email = @page.emails.build(params[:email])
    @email.created_by = @logged_user
    saved = @email.save
    
    # And the slot, don't forget the slot
    save_slot(@email) if saved

    respond_to do |format|
      if @email.save
        flash[:notice] = 'email was successfully created.'
        format.html { redirect_to(@email) }
        format.js {}
        format.xml  { render :xml => @email, :status => :created, :location => page_email_path(:page_id => @page.id, :id => @email.id) }
      else
        format.html { render :action => "new" }
        format.js {}
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /emails/1
  # PUT /emails/1.xml
  def update
    return error_status(true, :cannot_edit_email) unless (@email.can_be_edited_by(@logged_user))
    
    @email.updated_by = @logged_user

    respond_to do |format|
      if @email.update_attributes(params[:email])
        flash[:notice] = 'email was successfully updated.'
        format.html { redirect_to(@email) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /emails/1
  # DELETE /emails/1.xml
  def destroy
    return error_status(true, :cannot_delete_email) unless (@email.can_be_deleted_by(@logged_user))
    
    @slot_id = @email.page_slot.id
    @email.page_slot.destroy
    @email.updated_by = @logged_user
    @email.destroy

    respond_to do |format|
      format.html { redirect_to(emails_url) }
      format.js {}
      format.xml  { head :ok }
    end
  end
  
  def public
    return error_status(true, :cannot_see_email) unless (@email.can_be_seen_by(@logged_user))

    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

protected
 
  def authorized?(action = action_name, resource = nil)
    if action == 'public'
      public_auth
    else
      logged_in?
    end
  end
  
  def load_email
    begin
      @email = @page.emails.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      error_status(true, :cannot_find_email)
      return false
    end
  end
  
end
