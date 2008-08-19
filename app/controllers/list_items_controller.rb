class ListItemsController < ApplicationController
  before_filter :grab_page
  before_filter :grab_list
  
  # GET /list_items
  # GET /list_items.xml
  def index
    @list_items = @list.list_items.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @list_items }
    end
  end

  # GET /list_items/1
  # GET /list_items/1.xml
  def show
    @list_item = @list.list_items.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @list_item }
    end
  end

  # GET /list_items/new
  # GET /list_items/new.xml
  def new
    return error_status(true, :cannot_create_listitem) unless (ListItem.can_be_created_by(@logged_user, @list))
    
    @list_item = @list.list_items.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list_item }
    end
  end

  # GET /list_items/1/edit
  def edit
    @list_item = @list.list_items.find(params[:id])
    return error_status(true, :cannot_edit_listitem) unless (@list_item.can_be_edited_by(@logged_user))
  end

  # POST /list_items
  # POST /list_items.xml
  def create
    return error_status(true, :cannot_create_listitem) unless (ListItem.can_be_created_by(@logged_user, @list))
    
    @list_item = @list.list_items.build(params[:list_item])
    @list_item.created_by = @logged_user

    respond_to do |format|
      if @list_item.save
        flash[:notice] = 'ListItem was successfully created.'
        format.html { redirect_to(@list_item) }
        format.js
        format.xml  { render :xml => @list_item, :status => :created, :location => @list_item }
      else
        format.html { render :action => "new" }
        format.js
        format.xml  { render :xml => @list_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /list_items/1
  # PUT /list_items/1.xml
  def update
    @list_item = @list.list_items.find(params[:id])
    return error_status(true, :cannot_edit_listitem) unless (@list_item.can_be_edited_by(@logged_user))
    
    @list_item.updated_by = @logged_user

    respond_to do |format|
      if @list_item.update_attributes(params[:list_item])
        flash[:notice] = 'ListItem was successfully updated.'
        format.html { redirect_to(@list_item) }
        format.js
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js
        format.xml  { render :xml => @list_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /list_items/1
  # DELETE /list_items/1.xml
  def destroy
    @list_item = @list.list_items.find(params[:id])
    return error_status(true, :cannot_edit_listitem) unless (@list_item.can_be_deleted_by(@logged_user))
    
    @list_item.updated_by = @logged_user
    @list_item.destroy

    respond_to do |format|
      format.html { redirect_to(list_items_url) }
        format.js
      format.xml  { head :ok }
    end
  end
  
  # PUT /list_items/1
  def status
    @list_item = @list.list_items.find(params[:id])
    return error_status(true, :cannot_edit_listitem) unless (@list_item.can_be_completed_by(@logged_user))
    
    @list_item.set_completed(params[:list_item][:completed] == 'true', @logged_user)
    @list_item.position = @list.list_items.length
    @list_item.save

    respond_to do |format|
      format.html { redirect_to(list_items_url) }
      format.js
      format.xml  { head :ok }
    end

  end

protected

  def grab_list
    begin
        @list = @page.lists.find(params[:list_id])
    rescue ActiveRecord::RecordNotFound
        error_status(true, :cannot_find_list)
        return false
    end
    
    true
  end
end
