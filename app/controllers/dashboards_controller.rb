class DashboardsController < ApplicationController
  layout 'pages'
  
  # GET /dashboard
  def show
    @cached_users = {}
    @recent_activities = ApplicationLog.grouped_nicely(@logged_user).group_by do |obj|
      obj.created_on.to_date.to_s
    end.map do |date|
      [date[0], date[1].group_by { |obj| @cached_users[obj.created_by_id] ||= obj.created_by; obj.created_by_id }]
    end
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
