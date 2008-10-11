class JournalsController < ApplicationController
  layout 'pages'
  
  before_filter :grab_user
  
  # GET /journals
  # GET /journals.xml
  def index
    return error_status(true, :cannot_see_journals) unless (@user.journals_can_be_seen_by(@logged_user))
    
    @journals = get_groups
    @status = @user.status || @user.status.build()

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
