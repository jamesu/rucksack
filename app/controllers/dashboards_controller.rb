#==
# Copyright (C) 2008 James S Urquhart
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#++

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

protected

  def authorized?(action = action_name, resource = nil)
    logged_in? and @logged_user.member_of_owner?
  end
end
