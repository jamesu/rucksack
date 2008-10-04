class RemindersController < ApplicationController
  layout :reminder_layout
  
  before_filter :grab_user
  
  # GET /reminders
  # GET /reminders.xml
  def index
    #@reminders = @user.reminders
    return error_status(true, :cannot_see_reminders) unless (@user.reminders_can_be_seen_by(@logged_user))
    
    @grouped_reminders = get_groups
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reminders }
    end
  end

  # GET /reminders/1
  # GET /reminders/1.xml
  def show
    @reminder = @user.reminders.find(params[:id])
    return error_status(true, :cannot_see_reminder) unless (@reminder.can_be_seen_by(@logged_user))

    respond_to do |format|
      format.html # show.html.erb
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
    @reminder = @user.reminders.find(params[:id])
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
        format.js { @reminder_groups = get_groups; render :action => 'update' }
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
    @reminder = @user.reminders.find(params[:id])
    return error_status(true, :cannot_edit_reminder) unless (@reminder.can_be_edited_by(@logged_user))
    @reminder.updated_by = @logged_user

    respond_to do |format|
      if @reminder.update_attributes(params[:reminder])
        flash[:notice] = 'Reminder was successfully updated.'
        format.html { redirect_to(@reminder) }
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
    @reminder = @user.reminders.find(params[:id])
    return error_status(true, :cannot_delete_reminder) unless (@reminder.can_be_deleted_by(@logged_user))
    @reminder.updated_by = @logged_user
    @reminder.destroy

    respond_to do |format|
      format.html { redirect_to(reminders_url) }
      format.js { @reminder_groups = get_groups; render :action => 'update' }
      format.xml  { head :ok }
    end
  end

protected

  def get_groups
    groups = []
    
    @now = Time.zone.now
    return @user.reminders.on_after(@now.to_date).group_by do |obj|
        time = obj.at_time
        
        if time.year > @now.year # Distant future
            [time.strftime(:reminder_due_future.l), 'dueFuture', :date_format_md]
        elsif time.month > @now.month # Rest of year (monthly)
            [time.strftime(:reminder_due_months.l), "dueMonths#{time.month-@now.month}", :date_format_mwd]
        elsif time.day > @now.day+1 # Rest of the current month (excluding tomorrow)
            [time.strftime(:reminder_due_days.l), "dueDays#{time.day-@now.day}",  :date_format_time]
        elsif time.day > @now.day # Tomorrow
            [:reminder_due_tomorrow.l, 'dueTomorrow', :date_format_time]
        elsif time.day == @now.day and time > @now
            [:reminder_due_today.l, 'dueToday', (time.hour > @now.hour ? :due_format_hours : :due_upcomming)]
        else
            [:reminder_done.l, 'done', :done]
        end
    end
  end
  
  def reminder_layout
    'pages'
  end

end
