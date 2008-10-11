class UsersController < ApplicationController
  
  layout 'pages'
  
  after_filter  :user_track
    
  # GET /users
  # GET /users.xml
  def index
    @users = Account.owner.users.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users.to_xml(:except => [:salt, :token, :twister]) }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = Account.owner.users.find(params[:id])
    return error_status(true, :cannot_see_user) unless (@user.can_be_seen_by(@logged_user))

    respond_to do |format|
      format.html { redirect_to(users_path) }
      format.xml  { render :xml => @user.to_xml(:except => [:salt, :token, :twister]) }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    return error_status(true, :cannot_create_user) unless (User.can_be_created_by(@logged_user))
    
    @user = Account.owner.users.build()
    @user.is_admin = false

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user.to_xml(:except => [:salt, :token, :twister]) }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    return error_status(true, :cannot_edit_user) unless (@user.can_be_edited_by(@logged_user))
  end

  # POST /users
  # POST /users.xml
  def create
    return error_status(true, :cannot_create_user) unless (User.can_be_created_by(@logged_user))
    
    user_attribs = params[:user]
    
    @user = Account.owner.users.new(user_attribs)
    if @logged_user.is_admin
        @user.is_admin = user_attribs[:is_admin]
        @user.username = user_attribs[:username]
    end
    
    if user_attribs.has_key? :password and !user_attribs[:password].empty?
        @user.password = user_attribs[:password]
        @user.password_confirmation = user_attribs[:password_confirmation]
    end

    respond_to do |format|
      if @user.save
        flash[:notice] = 'user was successfully created.'
        format.html { redirect_to(users_path) }
        format.xml  { render :xml => @user.to_xml(:except => [:salt, :token, :twister]), :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = Account.owner.users.find(params[:id])
    return error_status(true, :cannot_edit_user) unless (@user.can_be_edited_by(@logged_user))
    
    user_attribs = params[:user]
    if @logged_user.is_admin
        @user.is_admin = user_attribs[:is_admin]
        @user.username = user_attribs[:username]
    end
    
    if user_attribs.has_key? :password and !user_attribs[:password].empty?
        @user.password = user_attribs[:password]
        @user.password_confirmation = user_attribs[:password_confirmation]
    end

    respond_to do |format|
      if @user.update_attributes(user_attribs)
        flash[:notice] = 'user was successfully updated.'
        format.html { redirect_to(users_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = Account.owner.users.find(params[:id])
    return error_status(true, :cannot_delete_user) unless (@user.can_be_deleted_by(@logged_user))
    
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.js { render :update do |page| page.redirect_to(users_url) end }
      format.xml  { head :ok }
    end
  end

  # GET /users/current
  def current
    @user = @logged_user
    
    render :action => 'edit'
  end
end
