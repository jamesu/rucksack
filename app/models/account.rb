class Account < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  has_many :users
  
  def self.owner(reload=false)
      @@cached_owner = nil if reload
      @@cached_owner ||= Account.find(:first)
  end
end
