import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/recurrence_rule_builder.dart';

void main() {
  group('RecurrenceRuleBuilder', () {
    test('builds daily RRULE with interval', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.daily,
        interval: 2,
      );

      final rule = builder.toRRule();

      expect(rule, 'FREQ=DAILY;INTERVAL=2');
    });

    test('builds weekly RRULE with sorted BYDAY', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        weeklyDays: <int>{DateTime.friday, DateTime.monday, DateTime.wednesday},
      );

      final rule = builder.toRRule();

      expect(rule, 'FREQ=WEEKLY;BYDAY=MO,WE,FR');
    });

    test('builds monthly RRULE with BYMONTHDAY', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
        monthlyDay: 15,
      );

      final rule = builder.toRRule();

      expect(rule, 'FREQ=MONTHLY;BYMONTHDAY=15');
    });

    test('builds RRULE with COUNT when recurrence end type is count', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.daily,
        endType: RecurrenceEndType.count,
        count: 5,
      );

      final rule = builder.toRRule();

      expect(rule, 'FREQ=DAILY;COUNT=5');
    });

    test('builds RRULE with UNTIL when recurrence end type is until', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.weekly,
        weeklyDays: <int>{DateTime.monday},
        endType: RecurrenceEndType.until,
        until: DateTime.utc(2026, 3, 31, 10, 30, 0),
      );

      final rule = builder.toRRule();

      expect(rule, 'FREQ=WEEKLY;BYDAY=MO;UNTIL=20260331T103000Z');
    });

    test('returns validation error when weekly days are empty', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.weekly,
      );

      final error = builder.validate();

      expect(error, isNotNull);
    });

    test('throws on invalid monthly day', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.monthly,
        monthlyDay: 0,
      );

      expect(builder.toRRule, throwsArgumentError);
    });

    test('throws when count end type is selected without count', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.daily,
        endType: RecurrenceEndType.count,
      );

      expect(builder.toRRule, throwsArgumentError);
    });

    test('throws when until end type is selected without date', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.daily,
        endType: RecurrenceEndType.until,
      );

      expect(builder.toRRule, throwsArgumentError);
    });
  });
}