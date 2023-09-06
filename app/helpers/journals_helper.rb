module JournalsHelper
  def fancy_journal_time(time)
    if @time_now > time + 1.day
      time.strftime(t('date_format_time'))
    else
      distance_of_time_in_words(time, Time.zone.now) + " ago"
    end
  end

  def friendly_time(seconds, complete=false)
    minutes = seconds / 60.0 # 22
    hours = minutes / 60.0   # 0.3
    hours = hours.floor
    minutes = (minutes - (hours * 60.0)).floor
    prefix = complete ? "✓" : "⏱"
    
    #return "#{hours}H#{minutes}M#{seconds}S"
      
    if hours < 1.0
      if minutes < 1
        return "#{prefix}#{seconds}S"
      else
        return "#{prefix}#{minutes}M"
      end
    else
      return "#{prefix}#{hours}H#{minutes}M"
    end
  end
end
