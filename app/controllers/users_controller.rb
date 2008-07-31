class UsersController < ApplicationController
  
  layout 'pages'
    
  before_filter :login_required
  after_filter  :user_track
    
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    user_attribs = params[:user]
    
    @user = User.new(user_attribs)
    @user.username = user_attribs[:username] if @logged_user.is_admin
    
    if user_attribs.has_key? :password and !user_attribs[:password].empty?
        @user.password = user_attribs[:password]
        @user.password_confirmation = user_attribs[:password_confirmation]
    end

    respond_to do |format|
      if @user.save
        flash[:notice] = 'user was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    
    user_attribs = params[:user]
    @user.username = user_attribs[:username] if @logged_user.is_admin
    if user_attribs.has_key? :password and !user_attribs[:password].empty?
        @user.password = user_attribs[:password]
        @user.password_confirmation = user_attribs[:password_confirmation]
    end

    respond_to do |format|
      if @user.update_attributes(user_attribs)
        flash[:notice] = 'user was successfully updated.'
        format.html { redirect_to(@user) }
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
    @user = User.find(params[:id])
    @user.destroy unless @user.is_admin # TODO

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  # GET /users/current
  def current
    @user = @logged_user
    
    render :action => 'edit'
  end
end
