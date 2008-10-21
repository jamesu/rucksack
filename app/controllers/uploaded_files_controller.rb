class UploadedFilesController < ApplicationController
  before_filter :grab_page
  
  # GET /uploaded_files
  # GET /uploaded_files.xml
  def index
    @uploaded_files = @page.uploaded_files.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @uploaded_files }
    end
  end

  # GET /uploaded_files/1
  # GET /uploaded_files/1.xml
  def show
    @uploaded_file = @page.uploaded_files.find(params[:id])
    @new_file = !params[:is_new].nil?
    
    @slot_id = @uploaded_file.page_slot.id
    slots = @page.slot_ids
    slots.each_index do |idx|
      if slots[idx] == @slot_id
        orig_id = idx < 0 ? 0 : slots[idx-1]
        @insert_element = orig_id == 0 ? "page_slot_footer" : "page_slot_#{orig_id}"
        break
      end
    end
    
    respond_to do |format|
      format.html { redirect_to @uploaded_file.data.url }
      format.js
      format.xml  { render :xml => @uploaded_file }
    end
  end

  # GET /uploaded_files/new
  # GET /uploaded_files/new.xml
  def new
    return error_status(true, :cannot_create_uploaded_file) unless (UploadedFile.can_be_created_by(@logged_user, @page))
    
    @uploaded_file = @page.uploaded_files.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @uploaded_file }
    end
  end

  # GET /uploaded_files/1/edit
  def edit
    @uploaded_file = @page.uploaded_files.find(params[:id])
    return error_status(true, :cannot_edit_uploaded_file) unless (@uploaded_file.can_be_edited_by(@logged_user))

    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /uploaded_files
  # POST /uploaded_files.xml
  def create
    return error_status(true, :cannot_create_uploaded_file) unless (UploadedFile.can_be_created_by(@logged_user, @page))
    
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
    @uploaded_file = @page.uploaded_files.build(params[:uploaded_file])
    @uploaded_file.created_by = @logged_user
    saved = @uploaded_file.save
    
    # And the slot, don't forget the slot
    if saved
      @slot = @page.new_slot_at(@uploaded_file, insert_id, @insert_before)
      @insert_element = insert_id == 0 ? 'page_slot_footer' : "page_slot_#{insert_id}"
    end

    respond_to do |format|
      if @uploaded_file.save
        flash[:notice] = 'uploaded_file was successfully created.'
        format.html { redirect_to(@uploaded_file.page) }
        format.js { render :action => 'create', :content_type => 'text/html' }
        format.xml  { render :xml => @uploaded_file, :status => :created, :location => @uploaded_file }
      else
        format.html { render :action => "new" }
        format.js { render :action => 'create', :content_type => 'text/html' }
        format.xml  { render :xml => @uploaded_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /uploaded_files/1
  # PUT /uploaded_files/1.xml
  def update
    @uploaded_file = @page.uploaded_files.find(params[:id])
    return error_status(true, :cannot_edit_uploaded_file) unless (@uploaded_file.can_be_edited_by(@logged_user))
    
    @uploaded_file.updated_by = @logged_user

    respond_to do |format|
      if @uploaded_file.update_attributes(params[:uploaded_file])
        flash[:notice] = 'uploaded_file was successfully updated.'
        format.html { redirect_to(@uploaded_file) }
        format.js { render :action => 'update', :content_type => 'text/html'  }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { render :action => 'update', :content_type => 'text/html' }
        format.xml  { render :xml => @uploaded_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /uploaded_files/1
  # DELETE /uploaded_files/1.xml
  def destroy
    @uploaded_file = @page.uploaded_files.find(params[:id])
    return error_status(true, :cannot_delete_uploaded_file) unless (@uploaded_file.can_be_deleted_by(@logged_user))
    
    @slot_id = @uploaded_file.page_slot.id
    @uploaded_file.page_slot.destroy
    @uploaded_file.updated_by = @logged_user
    @uploaded_file.destroy

    respond_to do |format|
      format.html { redirect_to(uploaded_files_url) }
      format.js {}
      format.xml  { head :ok }
    end
  end
end
