class Status < ActiveRecord::Base
  belongs_to :user

  # Common permissions
  
  def can_be_edited_by(user)
   return (user.is_admin or user.id == self.created_by_id)
  end
  
  def can_be_seen_by(user)
   return (user.is_admin or user.account_id == self.created_by.account_id)
  end
  
  # Accesibility
  
  attr_accessible :content
  
  # Validation
  
  validates_presence_of :content
end
