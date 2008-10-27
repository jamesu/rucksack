# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_rucksack_session_id'
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '1891570368d75c5be1519db4be2a1d14'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  before_filter :reload_owner
  before_filter :login_required
  before_filter :set_time_zone
  
protected
  
  def error_status(error, message, args={}, continue_ok=true)
  	flash[:error] = error
  	flash[:message] = message.l_with_args(args)
  	
  	return unless (error and continue_ok)
  	
  	# Construct a reply with a relevant error
  	respond_to do |format|
        format.html { redirect_back_or_default('/') }
        format.js { render(:update) do |page| 
                      page.replace_html('statusBar', h(flash[:message]))
                      page.show 'statusBar'
                    end }
        format.xml  { head(error ? :unprocessable_entity : :ok) }
  	end
  end
  
  def reload_owner
    Account.owner(true)
    true
  end
  
  def user_track
    if not @logged_user.nil?
      store_location
      User.update(@logged_user.id, {:last_visit => Time.now.utc})
    end
    true
  end
  
  def set_time_zone
    Time.zone = @logged_user.time_zone if @logged_user
    @time_now = Time.zone.now
  end
  
  def grab_page
    begin
        @page = Page.find(params[:page_id])
        return error_status(true, :insufficient_permissions) unless @page.can_be_seen_by(@logged_user)
    rescue ActiveRecord::RecordNotFound
        error_status(true, :error_cannot_find_page)
        return false
    end
    
    true
  end
  
  def grab_user
    begin
        @user = params.has_key?(:user_id) ? User.find(params[:user_id]) : @logged_user
    rescue ActiveRecord::RecordNotFound
        error_status(true, :error_cannot_find_user)
        return false
    end
    
    true
  end
  
  def public_auth
    # Make a temp anonymous user to check permissions
    @logged_user = User.new(:display_name => 'Anonymous')
    @logged_user.username = 'anonymous'
    @logged_user.is_anonymous = true
    return true
  end
  
  def calculate_position
    # Calculate target position
    # TODO: move to main controller as util function?
    if !params[:position].nil?
        pos = params[:position]
        @insert_id = pos[:slot].to_i
        if @insert_id < 0
          @insert_id = 0
          @insert_before = false
          @insert_footer = true
        else
          @insert_before = @insert_id == 0 ? true : (pos[:before].to_i == 1)
          @insert_footer = false
        end
    else
        @insert_id = nil
        @insert_before = true
        @insert_footer = false
    end
  end
  
  def save_slot(obj)
    @slot = @page.new_slot_at(obj, @insert_id, @insert_before)
    
    if @insert_footer
      @insert_element = 'page_slot_footer'
      @insert_before = true
    else
      @insert_element = @insert_id == 0 ? 'page_slot_footer' : "page_slot_#{@insert_id}"
    end
  end

end
