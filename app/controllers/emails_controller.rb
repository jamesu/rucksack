class EmailsController < ApplicationController
  layout nil
  
  before_filter :grab_page
  
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
    @email = @page.emails.find(params[:id])

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
    @email = @page.emails.find(params[:id])
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
    
    # Calculate target position
    # TODO: move to main controller as util function?
    if !params[:position].nil?
        pos = params[:position]
        insert_id = pos[:slot].to_i
        @insert_before = insert_id == 0 ? true : (pos[:before].to_i == 1)
    else
        insert_id = nil
        @insert_before = true
    end
    
    # Make the darn note
    @email = @page.emails.build(params[:email])
    @email.created_by = @logged_user
    saved = @email.save
    
    # And the slot, don't forget the slot
    if saved
        @slot = @page.new_slot_at(@email, insert_id, @insert_before)
        @insert_element = insert_id == 0 ? 'page_slot_footer' : "page_slot_#{insert_id}"
    end

    respond_to do |format|
      if @email.save
        flash[:notice] = 'email was successfully created.'
        format.html { redirect_to(@email) }
        format.js {}
        format.xml  { render :xml => @email, :status => :created, :location => @email }
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
    @email = @page.emails.find(params[:id])
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
    @email = @page.emails.find(params[:id])
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
end
