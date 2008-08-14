class Separator < ActiveRecord::Base
    belongs_to :page
    has_one :page_slot, :as => :rel_object
	
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    
    def view_partial
        "separators/show"
    end
    
    def self.form_partial
        "separators/form"
    end
    
	# Common permissions

	def self.can_be_created_by(user, page)
	   page.can_add_widget(user, Separator)
	end
	
	def can_be_edited_by(user)
	   self.page.can_be_edited_by(user)
	end
	
	def can_be_deleted_by(user)
	   self.page.can_be_edited_by(user)
	end
	
	def can_be_seen_by(user)
	   self.page.can_be_seen_by(user)
	end
	   
	# Accesibility
	
	attr_accessible :title
		
	# Validation
end
