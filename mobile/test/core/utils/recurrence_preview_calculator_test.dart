import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/recurrence_preview_calculator.dart';
import 'package:taskflow/core/utils/recurrence_rule_builder.dart';

void main() {
  final now = DateTime(2026, 6, 25, 10, 0);

  group('RecurrencePreviewCalculator', () {
    test('shows first task immediately and next ones 24h before deadline', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endType: RecurrenceEndType.never,
      );
      final templateDeadline = DateTime(2026, 6, 26, 10, 0);

      final result = RecurrencePreviewCalculator.previewFromBuilder(
        builder: builder,
        templateDeadline: templateDeadline,
        now: now,
      );

      expect(result, isNotNull);
      expect(result!.occurrences.length, 3);
      expect(result.occurrences.first.appearsImmediately, isTrue);
      expect(result.occurrences[1].appearsImmediately, isFalse);
      expect(
        result.occurrences[1].appearsAt,
        result.occurrences[1].deadline.subtract(const Duration(hours: 24)),
      );
      expect(result.repeatsForever, isTrue);
    });

    test('limits preview to recurrence count', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endType: RecurrenceEndType.count,
        count: 2,
      );
      final templateDeadline = DateTime(2026, 6, 26, 10, 0);

      final result = RecurrencePreviewCalculator.previewFromBuilder(
        builder: builder,
        templateDeadline: templateDeadline,
        now: now,
      );

      expect(result, isNotNull);
      expect(result!.occurrences.length, 2);
      expect(result.remainingCount, isNull);
    });

    test('shows remaining count when total exceeds preview', () {
      final builder = RecurrenceRuleBuilder(
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endType: RecurrenceEndType.count,
        count: 5,
      );
      final templateDeadline = DateTime(2026, 6, 26, 10, 0);

      final result = RecurrencePreviewCalculator.previewFromBuilder(
        builder: builder,
        templateDeadline: templateDeadline,
        now: now,
      );

      expect(result, isNotNull);
      expect(result!.occurrences.length, 3);
      expect(result.remainingCount, 2);
    });
  });
}
