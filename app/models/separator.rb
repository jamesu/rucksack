class Separator < ActiveRecord::Base
    belongs_to :page
    has_one :page_slot, :as => :rel_object
	
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    
    def view_partial
        "separator/show"
    end
    
    def self.form_partial
        "separator/form"
    end
    
	# Accesibility
	
	attr_accessible :title
		
	# Validation
end
