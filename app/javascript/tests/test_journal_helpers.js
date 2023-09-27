
import JournalHelpers from 'helpers/journal_helpers';

export default function runTests(QUnit) {

  QUnit.module('JournalHelpers', hooks => {
    QUnit.test('month_delta', assert => {
      var t1 = new Date(2023,1,1);
      var t2 = new Date(t1);
      JournalHelpers.incSecs(t2, (1*86400));

      assert.equal(JournalHelpers.calcMonthDelta(t1, t2), 0);

      JournalHelpers.incSecs(t2, (1*86400));
      assert.equal(JournalHelpers.calcMonthDelta(t1, t2), 0);

      JournalHelpers.incSecs(t2, (30*86400));
      assert.equal(JournalHelpers.calcMonthDelta(t1, t2), 1);
    });

    QUnit.test('calcMinuteDelta', assert => {
      var t1 = new Date(2023,1,1);
      var t2 = new Date(t1);
      JournalHelpers.incSecs(t2, 60);

      assert.equal(JournalHelpers.calcMinuteDelta(t1, t1), 0);
      assert.equal(JournalHelpers.calcMinuteDelta(t1, t2), 1);

      JournalHelpers.incSecs(t2, 20);
      assert.equal(JournalHelpers.calcMinuteDelta(t1, t2), 1);
    });

    QUnit.test('isNow', assert => {
      var t1 = new Date(2023,1,1);
      var t2 = new Date(t1);
      JournalHelpers.incSecs(t2, 1);

      assert.equal(JournalHelpers.isNow(t1, t1), true);
      assert.equal(JournalHelpers.isNow(t1, t2), true);

      JournalHelpers.incSecs(t2, 59);
      assert.equal(JournalHelpers.isNow(t1, t2), false);
    });

    QUnit.test('friendlyTime', assert => {
      assert.equal(JournalHelpers.friendlyTime(-1, null, true),    "✓-1S");
      assert.equal(JournalHelpers.friendlyTime(-1, null, false),   "⏱-1S");

      assert.equal(JournalHelpers.friendlyTime(1, null, true),     "✓1S");
      assert.equal(JournalHelpers.friendlyTime(59, null, true),    "✓59S");
      assert.equal(JournalHelpers.friendlyTime(60, null, true),    "✓1M");
      assert.equal(JournalHelpers.friendlyTime(61, null, true),    "✓1M");

      assert.equal(JournalHelpers.friendlyTime(60*59, null, true), "✓59M");
      assert.equal(JournalHelpers.friendlyTime(60*60, null, true), "✓1H0M");
      assert.equal(JournalHelpers.friendlyTime(60*61, null, true), "✓1H1M");
    
      // /
      
      assert.equal(JournalHelpers.friendlyTime(1, 1, true),     "✓1S");
      assert.equal(JournalHelpers.friendlyTime(1, 1, false),     "⏱1S/1S");
      assert.equal(JournalHelpers.friendlyTime(25, 59, false),    "⏱25S/59S");
      assert.equal(JournalHelpers.friendlyTime(30, 60, false),    "⏱30S/1M");
      assert.equal(JournalHelpers.friendlyTime(62, 61, false),    "⏱1M/1M");

      assert.equal(JournalHelpers.friendlyTime(60*30, 60*59, false), "⏱30M/59M");
      assert.equal(JournalHelpers.friendlyTime(60*30, 60*60, false), "⏱30M/1H0M");
      assert.equal(JournalHelpers.friendlyTime(60*30, 60*61, false), "⏱30M/1H1M");
    });

    QUnit.test('fancyJournalTime', assert => {
      var orig_time = new Date(2023,1,1);
      var now = new Date(2023,1,1);

      assert.equal(JournalHelpers.fancyJournalTime(orig_time, now), JournalHelpers.journalLocale('journal_now_time'));
      JournalHelpers.incSecs(now, 60*1);
      JournalHelpers.incSecs(now, 1);
      assert.equal(JournalHelpers.fancyJournalTime(orig_time, now), JournalHelpers.journalLocale('journal_minute_time', {'minutes': 1}));
      JournalHelpers.incSecs(now, 60*60);
      assert.equal(JournalHelpers.fancyJournalTime(orig_time, now), JournalHelpers.journalLocale('journal_hour_time', {'hours': 1}));
      JournalHelpers.incSecs(now, 60*60*24);
      assert.equal(JournalHelpers.fancyJournalTime(orig_time, now), JournalHelpers.journalLocale('journal_date_time', {'hours': "00", 'minutes': "00", 'year': 2023, 'month': 1, 'monthDay': 1, 'monthName': JournalHelpers.journalLocale('journal_month_1')}));
    });

  });

};
