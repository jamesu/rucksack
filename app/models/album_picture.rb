class AlbumPicture < ActiveRecord::Base
	belongs_to :album
	def page; self.album.page; end
	def page_id; self.album.page_id; end

  has_many :application_logs, :as => :rel_object, :dependent => :destroy
  
  has_attached_file :picture, :styles => { :album => "150x150#" }
  
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

  def object_name
    self.caption? ? self.caption : self.picture.original_filename
  end
	
	def set_position(value, user=nil)
	  self.position = value
	  self.updated_by = user unless user.nil?
	end

  # Common permissions
	
	def self.can_be_created_by(user, in_album)
	   in_album.picture_can_be_added_by(user)
	end
	
	def can_be_edited_by(user)
	   album.can_be_edited_by(user)
	end
	
	def can_be_deleted_by(user)
	   album.can_be_deleted_by(user)
	end
	
	def can_be_seen_by(user)
	   album.can_be_seen_by(user)
	end
	
	attr_accessible :caption, :picture
	
	# Validation
	
	validates_attachment_presence :picture
end
