import $ from "cash-dom";

export default {

  calcMonthDelta(date1, date2) {
    const year1 = date1.getFullYear();
    const month1 = date1.getMonth();
    const year2 = date2.getFullYear();
    const month2 = date2.getMonth();
    const totalMonths1 = (year1 * 12) + month1;
    const totalMonths2 = (year2 * 12) + month2;
    return totalMonths2 - totalMonths1;
  },

  calcMinuteDelta(date1, date2) {
    return Math.floor((date2 - date1) / 60000);
  },

  isNow(date, now) {
    return (now - date) < 60000;
  },

  substituteLocaleString(localeString, substitutions) {
    return localeString.replace(/%\{([^}]+)\}/g, (match, cap1) => {
      const value = substitutions !== undefined ? substitutions[cap1.trim()] : "";
      return value !== undefined ? value : match;
    });
  },

  journalLocale(key, substitutions) {
    if (this.journalStrings == null)
    {
      this.journalStrings = JSON.parse($('meta[name=journal-locale]').attr('value'));
    }

    return this.substituteLocaleString(this.journalStrings[key], substitutions);
  },

  friendlyTimePart(seconds) {
    var mul = seconds < 0 ? '-' : '';
    seconds = Math.abs(seconds);
    var minutes = seconds / 60.0;
    var hours = minutes / 60.0;
    hours = Math.floor(hours);
    minutes = Math.floor((minutes - (hours * 60.0)));
    seconds = Math.floor(seconds);

    if (hours < 1.0) 
    {
      if (minutes < 1) 
      {
        return mul + seconds.toString() + "S";
      } 
      else 
      {
        return mul + minutes.toString() + "M";
      }
    } 
    else
    {
      return mul + hours.toString() + "H" + minutes.toString() + "M";
    }
  },

  friendlyTime(seconds, seconds_limit, complete) {
    var prefix = complete ? "✓" : "⏱";
    if (complete || seconds_limit == null || seconds_limit == 0)
    {
      return prefix + this.friendlyTimePart(seconds);
    }
    else
    {
      return prefix + this.friendlyTimePart(seconds) + '/' + this.friendlyTimePart(seconds_limit);
    }
  },

  incSecs(date, amount) {
    date.setSeconds(date.getSeconds() + amount);
  },

  fancyJournalTime(date, now) {
    if (now == undefined)
      now = new Date();

    if (this.isNow(date, now))
    {
      return this.journalLocale('journal_now_time', {});
    } 
    else 
    {
      var minuteDelta = Math.floor(this.calcMinuteDelta(date, now));
      var hourDelta = Math.floor(minuteDelta / 60);
      var monthDelta = this.calcMonthDelta(date, now);

      if (monthDelta > 12)
      {
        var monthName = this.journalLocale('journal_month_' + (date.getMonth()+1).toString());
        return this.journalLocale('journal_year_time', {'year': date.getFullYear(), 'hours': date.getHours().toString().padStart(2, '0'), 'minutes': date.getMinutes().toString().padStart(2, '0'), 'month': (date.getMonth()+1).toString(), 'monthDay': date.getDate(), 'monthName': monthName});
      }
      else if (hourDelta > 24)
      {
        var monthName = this.journalLocale('journal_month_' + (date.getMonth()+1).toString());
        return this.journalLocale('journal_date_time', {'year': date.getFullYear(), 'hours': date.getHours().toString().padStart(2, '0'), 'minutes': date.getMinutes().toString().padStart(2, '0'), 'month': (date.getMonth()+1).toString(), 'monthDay': date.getDate(), 'monthName': monthName});
      }
      else if (minuteDelta > 60)
      {
        return this.journalLocale('journal_hour_time', {'hours': hourDelta});
      }
      else
      {
        return this.journalLocale('journal_minute_time', {'minutes': minuteDelta});
      }
    }
  }
};
