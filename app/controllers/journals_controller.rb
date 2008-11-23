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

class JournalsController < ApplicationController
  layout 'pages'
  
  before_filter :grab_user
  
  # GET /journals
  # GET /journals.xml
  def index
    return error_status(true, :cannot_see_journals) unless (@user.journals_can_be_seen_by(@logged_user))
    
    user_ids = Account.owner.user_ids - [@logged_user.id]
    @journals = get_groups
    @user_journals = user_ids.collect do |uid|
      journals = Journal.find(:all, :conditions => {'user_id' => uid},
                          :order => 'created_at DESC', :limit => 4)
      journals.empty? ? nil : [User.find_by_id(uid), journals]
    end.compact
    
    @status = @user.status || @user.build_status
    @content_for_sidebar = 'journals/users_sidebar'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @journals }
    end
  end

  # GET /journals/1
  # GET /journals/1.xml
  def show
    @journal = @user.journals.find(params[:id])
    return error_status(true, :cannot_see_journal) unless (@journal.can_be_seen_by(@logged_user))

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @journal }
    end
  end

  # GET /journals/new
  # GET /journals/new.xml
  def new
    return error_status(true, :cannot_create_journal) unless (Journal.can_be_created_by(@logged_user))
    @journal = @user.journals.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @journal }
    end
  end

  # GET /journals/1/edit
  def edit
    @journal = @user.journals.find(params[:id])
    return error_status(true, :cannot_edit_journal) unless (@journal.can_be_edited_by(@logged_user))
  end

  # POST /journals
  # POST /journals.xml
  def create
    return error_status(true, :cannot_create_journal) unless (Journal.can_be_created_by(@logged_user))
    @journal = @user.journals.build(params[:journal])

    respond_to do |format|
      if @journal.save
        @journals = get_groups
    
        flash[:notice] = 'Journal was successfully created.'
        format.html { redirect_to(@journal) }
        format.js { render :action => 'update' }
        format.xml  { render :xml => @journal, :status => :created, :location => @journal }
      else
        format.html { render :action => "new" }
        format.js {}
        format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /journals/1
  # PUT /journals/1.xml
  def update
    @journal = @user.journals.find(params[:id])
    return error_status(true, :cannot_edit_journal) unless (@journal.can_be_edited_by(@logged_user))

    respond_to do |format|
      if @journal.update_attributes(params[:journal])
        flash[:notice] = 'Journal was successfully updated.'
        format.html { redirect_to(@journal) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @journal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /journals/1
  # DELETE /journals/1.xml
  def destroy
    @journal = @user.journals.find(params[:id])
    return error_status(true, :cannot_delete_journal) unless (@journal.can_be_deleted_by(@logged_user))
    @journal.destroy

    respond_to do |format|
      format.html { redirect_to(journals_url) }
      format.xml  { head :ok }
    end
  end
  
protected

  def get_groups
    now = Time.zone.now.to_date
    @user.journals.find(:all).group_by do |journal|
	    date = journal.created_at.to_date
	    if date == now
	      :journal_date_today.l
	    else
	      date.strftime(date.year == now.year ? :journal_date_format.l : :journal_date_format_extended.l)
	    end
    end
  end
end
