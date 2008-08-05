class RemindersController < ApplicationController
  layout :reminder_layout
  
  before_filter :grab_user
  
  # GET /reminders
  # GET /reminders.xml
  def index
    #@reminders = @user.reminders
    
    @grouped_reminders = []
    
    found = @user.reminders.done
    @grouped_reminders << {:name => :reminder_done, :type => 'done', :reminders => found} unless found.empty?
    #found = @user.reminders.today(true)
    #@grouped_reminders << {:name => :reminder_due_today, :type => 'doneToday', :reminders => found} unless found.empty?
    found = @user.reminders.today(false)
    @grouped_reminders << {:name => :reminder_due_today, :type => 'dueToday', :reminders => found } unless found.empty?
    found = @user.reminders.in_days(1)
    @grouped_reminders << {:name => :reminder_due_tomorrow, :type => 'dueTomorrow', :reminders => found } unless found.empty?

    
    now = Time.now.utc
    
    # Rest of the current month (excluding tomorrow)
    ((now.day+1)...(Date.civil(now.year, now.month, -1).day)).each do |day|
        found = @user.reminders.in_days(day+1)
        @grouped_reminders << {:name => :reminder_due_days, :type => "doneDays#{day}", :reminders => found } unless found.empty?
    end
    
    # Rest of year (monthly)
    ((now.month)...12).each do |month|
        found = @user.reminders.in_month(month+1)
        @grouped_reminders << {:name => :reminder_due_months, :type => "doneMonths#{month+1}", :reminders =>found } unless found.empty?
    end
    
    # Distant future
    found = @user.reminders.on_after(Date.civil(now.year+1))
    @grouped_reminders << {:name => :reminder_due_future, :type => 'doneMonths', :reminders => found } unless found.empty?
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reminders }
    end
  end

  # GET /reminders/1
  # GET /reminders/1.xml
  def show
    @reminder = @user.reminders.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reminder }
    end
  end

  # GET /reminders/new
  # GET /reminders/new.xml
  def new
    @reminder = @user.reminders.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reminder }
    end
  end

  # GET /reminders/1/edit
  def edit
    @reminder = @user.reminders.find(params[:id])
  end

  # POST /reminders
  # POST /reminders.xml
  def create
    @reminder = @user.reminders.new(params[:reminder])

    respond_to do |format|
      if @reminder.save
        flash[:notice] = 'Reminder was successfully created.'
        format.html { redirect_to(reminders_path) }
        format.xml  { render :xml => @reminder, :status => :created, :location => @reminder }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reminder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reminders/1
  # PUT /reminders/1.xml
  def update
    @reminder = @user.reminders.find(params[:id])

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
    @reminder.destroy

    respond_to do |format|
      format.html { redirect_to(reminders_url) }
      format.xml  { head :ok }
    end
  end

protected

  def reminder_layout
    'pages'
  end

end
