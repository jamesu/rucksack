class PagesController < ApplicationController
  layout :page_layout
  
  before_filter :login_required
  before_filter :grab_user
  after_filter  :user_track
  
  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @pages }
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])
    @content_for_sidebar = 'page_sidebar'
    
    session['page_id'] = @page.id

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @page.to_json }
      format.xml  { render :xml => @page.to_xml(:include => [:slots, :notes, :lists]) }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
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
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = @user.pages.new(params[:page])

    respond_to do |format|
      if @page.save
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
    
    @slot.page = page
    @slot.position = page.slots.length
    @slot.save

    respond_to do |format|
      format.html { head :ok }
      format.js { }
      format.xml  { head :ok }
    end
  end
  
  def current
    begin
      if !session['page_id'].nil?
        page = Page.find(session['page_id'])
      else
        page = Page.find(:first)
      end
    rescue
      render :head => :not_found, :text => :page_not_found.l
    end
    
    redirect_to(page) unless page.nil?
  end
  
protected
  
  def page_layout
    return nil unless action_name != 'add_widget'
    ['index', 'new', 'edit'].include?(action_name)?  'pages':'page'
  end
end
