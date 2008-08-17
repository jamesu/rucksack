class Note < ActiveRecord::Base
    belongs_to :page
    has_one :page_slot, :as => :rel_object
	
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
	belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    
    def view_partial
        "notes/show"
    end
    
    def self.form_partial
        "notes/form"
    end
    
    def duplicate(new_page)
        new_note = self.clone
        new_note.created_by = new_page.created_by
        new_note.page = new_page
        
        new_note.save!
        new_note
    end

	# Common permissions

	def self.can_be_created_by(user, page)
	   page.can_add_widget(user, Note)
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
	
	attr_accessible :title, :content
	
	# Validation
	
	validates_presence_of :title
end
