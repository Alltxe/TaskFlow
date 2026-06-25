import 'package:rrule/rrule.dart';

import 'package:taskflow/core/utils/recurrence_rule_builder.dart';

/// Одна будущая задача в превью повторения.
class RecurrencePreviewOccurrence {
  const RecurrencePreviewOccurrence({
    required this.index,
    required this.deadline,
    required this.appearsAt,
    required this.appearsImmediately,
  });

  final int index;
  final DateTime deadline;
  final DateTime appearsAt;
  final bool appearsImmediately;
}

/// Результат расчёта превью повторяющихся задач.
class RecurrencePreviewResult {
  const RecurrencePreviewResult({
    required this.occurrences,
    this.remainingCount,
    this.repeatsForever = false,
  });

  final List<RecurrencePreviewOccurrence> occurrences;

  /// Сколько задач останется после показанных (для COUNT / UNTIL).
  final int? remainingCount;

  /// Повторение без даты окончания.
  final bool repeatsForever;
}

/// Расчёт превью по той же логике, что и backend RecurringTaskService.
class RecurrencePreviewCalculator {
  static const _appearBeforeDeadline = Duration(hours: 24);
  static const _defaultPreviewLimit = 3;
  static const _maxIterations = 1000;

  static RecurrencePreviewResult? preview({
    required String rruleString,
    required DateTime templateDeadline,
    RecurrenceEndType endType = RecurrenceEndType.never,
    int? count,
    DateTime? until,
    DateTime? now,
    int previewLimit = _defaultPreviewLimit,
  }) {
    final rule = _decodeRule(rruleString);
    if (rule == null) {
      return null;
    }

    final currentTime = now ?? DateTime.now();
    final anchor = _toRruleDateTime(templateDeadline);

    final first = _firstDeadline(rule, anchor);
    if (first == null) {
      return null;
    }

    final maxItems = _previewItemLimit(endType, count, previewLimit);
    final deadlines = <DateTime>[_fromRruleDateTime(first)];

    while (deadlines.length < maxItems) {
      final previous = deadlines.last;
      final next = _nextDeadline(rule, _toRruleDateTime(previous));
      if (next == null) {
        break;
      }

      final localNext = _fromRruleDateTime(next);
      if (_exceedsUntil(endType, until, localNext)) {
        break;
      }

      deadlines.add(localNext);
    }

    if (deadlines.isEmpty) {
      return null;
    }

    final occurrences = deadlines.asMap().entries.map((entry) {
      final index = entry.key;
      final deadline = entry.value;
      final appearsImmediately = index == 0;

      return RecurrencePreviewOccurrence(
        index: index + 1,
        deadline: deadline,
        appearsAt: appearsImmediately
            ? currentTime
            : deadline.subtract(_appearBeforeDeadline),
        appearsImmediately: appearsImmediately,
      );
    }).toList();

    final totalCount = _totalOccurrences(
      rruleString: rruleString,
      templateDeadline: templateDeadline,
      endType: endType,
      count: count,
      until: until,
    );

    final shown = occurrences.length;
    final remaining = totalCount != null && totalCount > shown
        ? totalCount - shown
        : null;

    return RecurrencePreviewResult(
      occurrences: occurrences,
      remainingCount: remaining,
      repeatsForever: endType == RecurrenceEndType.never,
    );
  }

  static RecurrencePreviewResult? previewFromBuilder({
    required RecurrenceRuleBuilder builder,
    required DateTime templateDeadline,
    DateTime? now,
    int previewLimit = _defaultPreviewLimit,
  }) {
    final validationError = builder.validate();
    if (validationError != null) {
      return null;
    }

    return preview(
      rruleString: builder.toRRule(),
      templateDeadline: templateDeadline,
      endType: builder.endType,
      count: builder.endType == RecurrenceEndType.count ? builder.count : null,
      until: builder.endType == RecurrenceEndType.until ? builder.until : null,
      now: now,
      previewLimit: previewLimit,
    );
  }

  static RecurrenceRule? _decodeRule(String rruleString) {
    try {
      final trimmed = rruleString.trim();
      final normalized = trimmed.startsWith('RRULE:') ? trimmed : 'RRULE:$trimmed';
      return const RecurrenceRuleStringCodec().decode(normalized);
    } catch (_) {
      return null;
    }
  }

  static DateTime _toRruleDateTime(DateTime value) {
    return value.copyWith(isUtc: true);
  }

  static DateTime _fromRruleDateTime(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
    );
  }

  static DateTime? _firstDeadline(RecurrenceRule rule, DateTime anchor) {
    final instances = rule.getInstances(
      start: anchor,
      after: anchor,
      includeAfter: true,
    );

    final iterator = instances.iterator;
    if (!iterator.moveNext()) {
      return null;
    }

    return iterator.current;
  }

  static DateTime? _nextDeadline(RecurrenceRule rule, DateTime anchor) {
    final instances = rule.getInstances(
      start: anchor,
      after: anchor,
      includeAfter: false,
    );

    final iterator = instances.iterator;
    if (!iterator.moveNext()) {
      return null;
    }

    return iterator.current;
  }

  static int _previewItemLimit(
    RecurrenceEndType endType,
    int? count,
    int previewLimit,
  ) {
    if (endType == RecurrenceEndType.count && count != null) {
      return count < previewLimit ? count : previewLimit;
    }

    return previewLimit;
  }

  static bool _exceedsUntil(
    RecurrenceEndType endType,
    DateTime? until,
    DateTime deadline,
  ) {
    if (endType != RecurrenceEndType.until || until == null) {
      return false;
    }

    return deadline.isAfter(until);
  }

  static int? _totalOccurrences({
    required String rruleString,
    required DateTime templateDeadline,
    required RecurrenceEndType endType,
    int? count,
    DateTime? until,
  }) {
    if (endType == RecurrenceEndType.count) {
      return count;
    }

    if (endType == RecurrenceEndType.never) {
      return null;
    }

    if (endType != RecurrenceEndType.until || until == null) {
      return null;
    }

    final rule = _decodeRule(rruleString);
    if (rule == null) {
      return null;
    }

    final anchor = _toRruleDateTime(templateDeadline);
    final firstOccurrence = _firstDeadline(rule, anchor);
    if (firstOccurrence == null) {
      return 0;
    }

    var current = firstOccurrence;
    var total = 1;
    for (var i = 0; i < _maxIterations; i++) {
      final local = _fromRruleDateTime(current);
      if (local.isAfter(until)) {
        return total - 1;
      }

      final next = _nextDeadline(rule, _toRruleDateTime(local));
      if (next == null) {
        return total;
      }

      final localNext = _fromRruleDateTime(next);
      if (localNext.isAfter(until)) {
        return total;
      }

      total += 1;
      current = next;
    }

    return total;
  }
}
