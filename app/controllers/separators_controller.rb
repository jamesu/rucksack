class SeparatorsController < ApplicationController
  before_filter :grab_page
  
  # GET /separators
  # GET /separators.xml
  def index
    @separators = @page.separators.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @separators }
    end
  end

  # GET /separators/1
  # GET /separators/1.xml
  def show
    @separator = @page.separators.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @separator }
    end
  end

  # GET /separators/new
  # GET /separators/new.xml
  def new
    return error_status(true, :cannot_create_separator) unless (Separator.can_be_created_by(@logged_user, @page))
    
    @separator = @page.separators.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @separator }
    end
  end

  # GET /separators/1/edit
  def edit
    @separator = @page.separators.find(params[:id])
    return error_status(true, :cannot_edit_separator) unless (@separator.can_be_edited_by(@logged_user))

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /separators
  # POST /separators.xml
  def create
    return error_status(true, :cannot_create_separator) unless (Separator.can_be_created_by(@logged_user, @page))
    
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
    @separator = @page.separators.build(params[:separator])
    @separator.created_by = @logged_user
    saved = @separator.save
    
    # And the slot, don't forget the slot
    if saved
        @slot = @page.new_slot_at(@separator, insert_id, @insert_before)
        @insert_element = insert_id == 0 ? 'page_slot_footer' : "page_slot_#{insert_id}"
    end

    respond_to do |format|
      if @separator.save
        flash[:notice] = 'Separator was successfully created.'
        format.html { redirect_to(@separator) }
        format.js {}
        format.xml  { render :xml => @separator, :status => :created, :location => @separator }
      else
        format.html { render :action => "new" }
        format.js {}
        format.xml  { render :xml => @separator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /separators/1
  # PUT /separators/1.xml
  def update
    @separator = @page.separators.find(params[:id])
    return error_status(true, :cannot_edit_separator) unless (@separator.can_be_edited_by(@logged_user))
    
    @separator.updated_by = @logged_user

    respond_to do |format|
      if @separator.update_attributes(params[:separator])
        flash[:notice] = 'Separator was successfully updated.'
        format.html { redirect_to(@separator) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @separator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /separators/1
  # DELETE /separators/1.xml
  def destroy
    @separator = @page.separators.find(params[:id])
    return error_status(true, :cannot_delete_separator) unless (@separator.can_be_deleted_by(@logged_user))
    
    @slot_id = @separator.page_slot.id
    @separator.page_slot.destroy
    @separator.updated_by = @logged_user
    @separator.destroy

    respond_to do |format|
      format.html { redirect_to(separators_url) }
      format.js {}
      format.xml  { head :ok }
    end
  end
end
