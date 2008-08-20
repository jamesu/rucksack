class DashboardsController < ApplicationController
  layout 'pages'
  
  # GET /dashboard
  def show
    # Group by creator, page, and date so we eliminate multiple references to the same page in a single day.
    # Non-page objectes are handled by a CASE. Better check with your db's SQL to see if that is supported. Works in SQLITE
    @recent_activities = ApplicationLog.find(:all, :order => 'created_on DESC', :select => 'created_by_id, rel_object_id, rel_object_type, object_name, page_id, action_id, date(created_on) AS sorted_on, created_on', :group => 'created_by_id, CASE page_id ISNULL WHEN 1 THEN rel_object_type || rel_object_id ELSE page_id END, sorted_on').group_by do |obj|
        obj.created_on.utc.to_date.to_s
    end
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
