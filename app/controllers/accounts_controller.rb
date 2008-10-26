class AccountsController < ApplicationController
  layout 'pages'

  # GET /settings
  # GET /settings.xml
  def show
    @account = Account.owner

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  # PUT /settings
  # PUT /settings.xml
  def update
    @account = Account.owner

    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = :settings_updated.l
        format.html { redirect_back_or_default(:action => 'show') }
        format.xml  { head :ok }
      else
        format.html { render :action => "show" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def authorized?(action = action_name, resource = nil)
    logged_in? and @logged_user.owner_of_owner?
  end

end
