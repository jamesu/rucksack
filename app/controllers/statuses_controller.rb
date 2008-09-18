class StatusesController < ApplicationController
  layout 'pages'
  
  before_filter :grab_user

  # GET /statuses/1
  # GET /statuses/1.xml
  def show
    @status = @user.status

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @status }
    end
  end

  # PUT /statuses/1
  # PUT /statuses/1.xml
  def index
    @status = @user.status || @user.build_status
    
    @status.attributes = params[:status]

    respond_to do |format|
      if @status.save
        flash[:notice] = 'Status was successfully updated.'
        format.html { redirect_to(journals_url) }
        format.js {}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js {}
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end
end
