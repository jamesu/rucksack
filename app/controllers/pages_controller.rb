class PagesController < ApplicationController
  layout :page_layout
  
  before_filter :grab_user
  before_filter :search, :only => :index
  after_filter  :user_track, :except => 'public'
  
  # GET /pages
  # GET /pages.xml
  def index
    return error_status(true, :cannot_see_pages) unless (@user.pages_can_be_seen_by(@logged_user))
    
    if @find_opts.nil?
      @pages = @user.pages
      @shared_pages = @user.shared_pages
    else
      @pages = @user.pages.find(:all, @find_opts)
      @shared_pages = @user.shared_pages(:all, @find_opts)
    end
    
    @content_for_sidebar = 'page_sidebar'

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render :json => @pages }
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])
    return error_status(true, :cannot_see_page) unless (@page.can_be_seen_by(@logged_user))
    
    @content_for_sidebar = 'page_sidebar'
    
    session['page_id'] = @page.id

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @page.to_json }
      format.xml  { render :xml => @page.to_xml }
    end
  end
  
  # GET /pages/1/public(.html)
  def public
    @page = Page.find(params[:id])
    #return error_status(true, :cannot_see_page) unless (@page.can_be_seen_by(@logged_user))

    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    return error_status(true, :cannot_create_page) unless ((@logged_user.id == @user.id) and Page.can_be_created_by(@user))
    
    @page = @user.pages.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @page.to_json }
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
    return error_status(true, :cannot_edit_page) unless (@page.can_be_edited_by(@logged_user))
  end

  # POST /pages
  # POST /pages.xml
  def create
    return error_status(true, :cannot_create_page) unless ((@logged_user.id == @user.id) and Page.can_be_created_by(@user))
    @page = @user.pages.new(params[:page])

    respond_to do |format|
      if @page.save
        @user.favourite_pages << @page
        
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to(@page) }
        format.json { render :json => @page.to_json }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find(params[:id])
    return error_status(true, :cannot_edit_page) unless (@page.can_be_edited_by(@logged_user))

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(@page) }
        format.js { }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    return error_status(true, :cannot_delete_page) unless (@page.can_be_deleted_by(@logged_user))
    
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.json { } # destroy.js.rjs
      format.xml  { head :ok }
    end
  end
  
  # POST /pages/1/reorder
  def reorder
    page = Page.find(params[:id])
    return error_status(true, :insufficient_permissions) unless (page.can_be_edited_by(@logged_user))
    
    order = params[:slots].collect { |id| id.to_i }
    
    page.slots.each do |slot|
        idx = order.index(slot.id)
        slot.position = idx
        slot.save!
    end

    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
      format.xml  { head :ok }
    end
  end
  
  # PUT /pages/1/transfer
  def transfer
    page = Page.find(params[:id])
    @slot = PageSlot.find(params[:page_slot][:id])
    
    return error_status(true, :insufficient_permissions) unless (page.can_be_edited_by(@logged_user) and @slot.page.can_be_edited_by(@logged_user))
    
    @slot.page = page
    @slot.rel_object.page = page
    @slot.rel_object.save
    @slot.position = page.slots.length
    @slot.save

    respond_to do |format|
      format.html { head :ok }
      format.js { }
      format.xml  { head :ok }
    end
  end
  
  def favourite
    @page = Page.find(params[:id])
    return error_status(true, :insufficient_permissions) unless (@user.can_add_favourite(@logged_user))
    
    @set_favourite = params[:page][:is_favourite].to_i != 0
    if @set_favourite
        @user.favourite_pages << @page unless @page.is_favourite?(@user)
    else
        @user.favourite_pages.delete(@page)
    end

    respond_to do |format|
      format.html { head :ok }
      format.js { }
      format.xml  { head :ok }
    end
  end
  
  def share
    @page = Page.find(params[:id])
    return error_status(true, :insufficient_permissions) unless (@page.can_be_shared_by(@logged_user))
    
    grab_users = Proc.new {|sid| 
        begin
            User.find(sid)
        rescue ActiveRecord::RecordNotFound
            nil
        end}
    
    set_users = []
    unless params[:page].nil?
        set_users = params[:page][:shared_users]
        set_users ||= []
    end
    
    case request.method
    when :get
    when :post
        # Set afresh
        unless set_users.nil?
            @page.shared_users = set_users.collect(&grab_users).compact
        end
    when :put
        # Insert into list
        unless set_users.nil?
            set_users.collect(&grab_users).compact.each {|user| @page.shared_users << user unless @page.shared_users_ids.include?(user.id)}
        end
    when :delete
        # Delete from list
        unless set_users.nil?
            set_users.collect(&grab_users).compact.each {|user| @page.shared_users.delete(user)}
        end
    end

    respond_to do |format|
      format.html { if request.method != :get; redirect_to(page_url(@page)) end }
      format.js { }
      format.xml  { head :ok }
    end
  end
  
  def current
    begin
      if !session['page_id'].nil?
        page = Page.find(session['page_id'])
        unless page.can_be_seen_by(@logged_user)
            page = @user.pages.first
            session['page_id'] = page.id
        end
      else
        page = @user.pages.first
      end
    rescue
      page = @user.pages.first
      session['page_id'] = page.id
    end
    
    unless page.nil?
      redirect_to(page)
    else
      redirect_to(pages_url)
    end
  end
  
  def duplicate
    @page = Page.find(params[:id])
    return error_status(true, :cannot_duplicate_page) unless (@page.can_be_duplicated_by(@logged_user))
    
    begin
        @new_page = @page.duplicate(@logged_user)
        @logged_user.favourite_pages << @new_page
    rescue Object => o
        logger.warn o
        return error_status(true, :cannot_duplicate_page)
    end
    
    respond_to do |format|
      format.html { head :ok }
      format.js { }
      format.xml  { head :ok }
    end 
  end
  
  def tags
    @page = Page.find(params[:id])
    return error_status(true, :cannot_edit_page) unless (@page.can_be_edited_by(@logged_user))
       
    case request.method
      when :get
        @view = 'tags_form'
      when :post
        @page.tags = params[:page][:tags]
        @view = 'tags'
        @page.save
    end
    
    respond_to do |format|
      format.html { head :ok }
      format.js { render :action => @view }
      format.xml  { head :ok }
    end 
  end
  
protected
  
  def protect?(action)
    if action == 'public'
      # Make a temp anonymous user to check permissions
      @logged_user = User.new(:username => 'anonymous', :display_name => 'Anonymous')
      return false
    end
    
    true
  end
  
  def search
    @find_opts = nil
    if !params[:tags].nil? and params[:tags].class == Array
      @search_tags = params[:tags]
      @find_opts = {:conditions => ['tags.name IN (?)', params[:tags]],
                    :joins => Tag.find_object_join(Page),
                    :group => "pages.id HAVING COUNT(tags.id) = #{params[:tags].length}"}
      puts @find_opts
      
      @avail_tags = Tag.list_in_page(nil) - @search_tags
    else
      @avail_tags = Tag.list_in_page(nil)
    end
  end
  
  def page_layout
    return nil unless action_name != 'add_widget'
    return 'public_page' if action_name == 'public'
    ['index', 'new', 'edit'].include?(action_name)?  'pages':'page'
  end
end
