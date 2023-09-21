module JournalsHelper
  def calc_month_delta(date1, date2)
    year1 = date1.year
    month1 = date1.month
    year2 = date2.year
    month2 = date2.month
    totalMonths1 = (year1 * 12) + month1
    totalMonths2 = (year2 * 12) + month2
    return totalMonths2 - totalMonths1
  end

  def calc_minute_delta(date1, date2)
    return ((date2 - date1) / 60.0).floor
  end

  def is_now(date, now)
    return (now - date) < 60
  end

  def friendly_time(seconds, complete=false)
    minutes = seconds / 60.0
    hours = minutes / 60.0
    hours = (hours).floor
    minutes = ((minutes - (hours * 60.0))).floor
    prefix = complete ? "✓" : "⏱"
    seconds = (seconds).floor

    if (hours < 1.0) then
      if (minutes < 1) then
        return "#{prefix}#{seconds}S"
      else
        return "#{prefix}#{minutes}M"
      end
    else
      return "#{prefix}#{hours}H#{minutes}M"
    end
  end

  def fancy_journal_time(date)
    now = Time.new
    if (is_now(date, now)) then
      return I18n.t('journal_now_time')
    else
      minuteDelta = (calc_minute_delta(date, now)).floor
      hourDelta = (minuteDelta / 60.0).floor
      monthDelta = calc_month_delta(date, now)

      if (monthDelta > 12) then
        monthName = I18n.t('journal_month_' + date.month.to_s)
        return I18n.t('journal_year_time', hours: "%02i" % date.hour, minutes: "%02i" % date.min, year: date.year, month: date.month, monthDay: date.mday, monthName: monthName)
      elsif (hourDelta > 24) then
        monthName = I18n.t('journal_month_' + date.month.to_s)
        return I18n.t('journal_date_time', hours: "%02i" % date.hour, minutes: "%02i" % date.min, year: date.year, month: date.month, monthDay: date.mday, monthName: monthName)
      elsif (minuteDelta > 60) then
        return I18n.t('journal_hour_time', hours: hourDelta)
      else
        return I18n.t('journal_minute_time', minutes: minuteDelta)
      end
    end
  end

  def journal_locale_strings
    list = %w{journal_year_time journal_date_time journal_hour_time journal_minute_time journal_now_time journal_month_1 journal_month_2 journal_month_3 journal_month_4 journal_month_5 journal_month_6 journal_month_7 journal_month_8 journal_month_9 journal_month_10 journal_month_11 journal_month_12}
    return list.reduce({}) { |ht, w| ht[w] = I18n.t(w, resolve: false); ht }
  end
end
