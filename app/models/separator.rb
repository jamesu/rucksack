class Separator < ActiveRecord::Base
    belongs_to :page
    has_one :page_slot, :as => :rel_object
	
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
	
	after_create   :process_create
	before_update  :process_update_params
	before_destroy :process_destroy
	
	def process_create
	  ApplicationLog.new_log(self, self.created_by, :add)
	end
	
	def process_update_params
	  ApplicationLog.new_log(self, self.updated_by, :edit)
	end
	
	def process_destroy
	  ApplicationLog.new_log(self, self.updated_by, :delete)
	end
	    
    def view_partial
        "separators/show"
    end
    
    def self.form_partial
        "separators/form"
    end
    
    def duplicate(new_page)
        new_separator = self.clone
        new_separator.created_by = new_page.created_by
        new_separator.page = new_page
        
        new_separator.save!
        new_separator
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
