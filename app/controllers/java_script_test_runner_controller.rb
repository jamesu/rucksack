class JavaScriptTestRunnerController < ApplicationController
	skip_before_action :login_required
	
	def run
	end
end
