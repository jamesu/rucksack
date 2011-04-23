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

class RemindersController < ApplicationController
  layout :reminder_layout
  
  before_filter :grab_user
  before_filter :load_reminder, :except => [:index, :new, :create]
  
  
  # GET /reminders
  # GET /reminders.xml
  def index
    return error_status(true, :cannot_see_reminders) unless (@user.reminders_can_be_seen_by(@logged_user))
    
    @grouped_reminders = get_groups
    
    respond_to do |format|
      format.html # index.html.erb
      format.js { render :action => 'update' }
      format.xml  { render :xml => @reminders }
    end
  end

  # GET /reminders/1
  # GET /reminders/1.xml
  def show
    return error_status(true, :cannot_see_reminder) unless (@reminder.can_be_seen_by(@logged_user))

    respond_to do |format|
      format.html { redirect_to reminders_path } # show.html.erb
      format.xml  { render :xml => @reminder }
    end
  end

  # GET /reminders/new
  # GET /reminders/new.xml
  def new
    return error_status(true, :cannot_create_reminder) unless (Reminder.can_be_created_by(@logged_user))
    @reminder = @user.reminders.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reminder }
    end
  end

  # GET /reminders/1/edit
  def edit
    return error_status(true, :cannot_edit_reminder) unless (@reminder.can_be_edited_by(@logged_user))
  end

  # POST /reminders
  # POST /reminders.xml
  def create
    return error_status(true, :cannot_create_reminder) unless (Reminder.can_be_created_by(@logged_user))
    @reminder = @user.reminders.new(params[:reminder])

    respond_to do |format|
      if @reminder.save
        flash[:notice] = 'Reminder was successfully created.'
        format.html { redirect_to(reminders_path) }
        format.js { @grouped_reminders = get_groups; render :action => 'update' }
        format.xml  { render :xml => @reminder, :status => :created, :location => @reminder }
      else
        format.html { render :action => "new" }
        format.js { render :action => 'update' }
        format.xml  { render :xml => @reminder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reminders/1
  # PUT /reminders/1.xml
  def update
    return error_status(true, :cannot_edit_reminder) unless (@reminder.can_be_edited_by(@logged_user))
    @reminder.updated_by = @logged_user

    respond_to do |format|
      if @reminder.update_attributes(params[:reminder])
        flash[:notice] = 'Reminder was successfully updated.'
        format.html { redirect_to(@reminder) }
        format.js { @grouped_reminders = get_groups; render :action => 'update' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reminder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reminders/1
  # DELETE /reminders/1.xml
  def destroy
    return error_status(true, :cannot_delete_reminder) unless (@reminder.can_be_deleted_by(@logged_user))
    @reminder.updated_by = @logged_user
    @reminder.destroy

    respond_to do |format|
      format.html { redirect_to(reminders_url) }
      format.js
      format.xml  { head :ok }
    end
  end
  
  def snooze
    return error_status(true, :cannot_edit_reminder) unless (@reminder.can_be_edited_by(@logged_user))
    @reminder.updated_by = @logged_user
    @reminder.snooze

    respond_to do |format|
      if @reminder.save
        flash[:notice] = 'Reminder was successfully updated.'
        format.html { redirect_to(@reminder) }
        format.js { @grouped_reminders = get_groups; render :action => 'update' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reminder.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def load_reminder
    begin
      @reminder = @user.reminders.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      error_status(true, :cannot_find_reminder)
      return false
    end
    
    true
  end

  def get_groups
    groups = []
    
    @now = Time.zone.now
    return @user.reminders.on_after(@now.to_date).group_by do |obj|
        time = obj.at_time
        
        if time.year > @now.year # Distant future
            [time.strftime(t('reminder_due_future')), 'dueFuture', :date_format_md]
        elsif time.month > @now.month # Rest of year (monthly)
            [time.strftime(t('reminder_due_months')), "dueMonths#{time.month-@now.month}", :date_format_mwd]
        elsif time.day > @now.day+1 # Rest of the current month (excluding tomorrow)
            [time.strftime(t('reminder_due_days')), "dueDays#{time.day-@now.day}",  :date_format_time]
        elsif time.day > @now.day # Tomorrow
            [t('reminder_due_tomorrow'), 'dueTomorrow', :date_format_time]
        elsif time.day == @now.day and time > @now
            [t('reminder_due_today'), 'dueToday', (time.hour > @now.hour ? :due_format_hours : :due_upcomming)]
        else
            [t('reminder_done'), 'done', :done]
        end
    end.map{|k,v| [k,v]}
  end
  
  def reminder_layout
    'pages'
  end

end
