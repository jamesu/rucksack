require 'test_helper'

class JournalsHelperTest < ActionView::TestCase
  include JournalsHelper

  def test_month_delta
    t1 = Time.new(2023,1,1)
    t2 = t1 + 1.day
    assert_equal 0, calc_month_delta(t1, t2)

    t2 += 1.day
    assert_equal 0, calc_month_delta(t1, t2)

    t2 += 30.days
    assert_equal 1, calc_month_delta(t1, t2)
  end

  def test_calc_minute_delta
    t1 = Time.new(2023,1,1)
    t2 = t1 + 1.minute

    assert_equal 0, calc_minute_delta(t1, t1)
    assert_equal 1, calc_minute_delta(t1, t2)

    t2 += 20.seconds
    assert_equal 1, calc_minute_delta(t1, t2)
  end

  def test_is_now
    t1 = Time.new(2023,1,1)
    t2 = t1 + 1.second

    assert_equal true, is_now(t1, t1)
    assert_equal true, is_now(t1, t2)

    t2 += 59.seconds
    assert_equal false, is_now(t1, t2)
  end

  def test_friendly_time
    assert_equal "✓-1S", friendly_time(-1, nil, true)
    assert_equal "⏱-1S", friendly_time(-1, nil, false)

    assert_equal "✓1S", friendly_time(1, nil, true)
    assert_equal "✓59S", friendly_time(59, nil, true)
    assert_equal "✓1M", friendly_time(60, nil, true)
    assert_equal "✓1M", friendly_time(61, nil, true)

    assert_equal "✓59M", friendly_time(60*59, nil, true)
    assert_equal "✓1H0M", friendly_time(60*60, nil, true)
    assert_equal "✓1H1M", friendly_time(60*61, nil, true)

    # /

    assert_equal "✓1S", friendly_time(1, 1, true)
    assert_equal "⏱1S/1S", friendly_time(1, 1, false)
    assert_equal "⏱25S/59S", friendly_time(25, 59, false)
    assert_equal "⏱30S/1M", friendly_time(30, 60, false)
    assert_equal "⏱1M/1M", friendly_time(62, 61, false)

    assert_equal "⏱30M/59M", friendly_time(60*30, 60*59, false)
    assert_equal "⏱30M/1H0M", friendly_time(60*30, 60*60, false)
    assert_equal "⏱30M/1H1M", friendly_time(60*30, 60*61, false)
  end

  def test_fancy_journal_time
    orig_time = Time.new(2023,1,1)
    now = Time.new(2023,1,1)
    assert_equal I18n.t('journal_now_time'), fancy_journal_time(orig_time, now)
    now += 1.minute
    now += 1.second
    assert_equal I18n.t('journal_minute_time', minutes: 1), fancy_journal_time(orig_time, now)
    now += 60.minutes
    assert_equal I18n.t('journal_hour_time', hours: 1), fancy_journal_time(orig_time, now)
    now += 24.hours
    assert_equal I18n.t('journal_date_time', hours: "00", minutes: "00", year: 2023, month: 1, monthDay: 1, monthName: I18n.t('journal_month_1')), fancy_journal_time(orig_time, now)
  end

end