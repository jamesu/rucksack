require 'chronic'

class Reminder < ActiveRecord::Base
	belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  
    @@repeat_lookup = {:never => 0, :yearly => 1, :monthly => 2, :fortnightly => 3, :weekly => 4, :daily => 5}
    @@repeat_id_lookup = @@repeat_lookup.invert
    
    def friendly_at_time
        @cached_friendly_time || self.at_time.to_s
    end
    
    def friendly_at_time=(value)
        @cached_friendly_time = value
        self.at_time = Chronic.parse(value)
        self.at_time ||= Time.now + (60*60*3)
        # TODO: set default time if Chronic craps up. Also try extracting times from query
        self.content = value
    end
  
    def friendly_repeat
        "reminder_repeat_#{self.repeat}".to_sym.l
    end
  
    def repeat
        @@repeat_id_lookup[self.repeat_id]
    end
  
    def repeat=(val)
        self.repeat_id = @@repeat_lookup[val.to_sym]
    end
    
    def repeatable?
        self.repeat_id > 0
    end
    
    def self.select_repeat
        @@repeat_lookup.keys.map do |key|
            ["reminder_repeat_#{self.repeat}".to_sym.l, key]
        end
    end
	
	# Accesibility
	
	attr_accessible :repeat, :friendly_at_time, :content, :at_time
end
