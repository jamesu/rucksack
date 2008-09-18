class Status < ActiveRecord::Base
  belongs_to :user
	
	# Accesibility
	
	attr_accessible :content
	
	# Validation
	
	validates_presence_of :content
end
