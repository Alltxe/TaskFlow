enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
}

enum RecurrenceEndType {
  never,
  count,
  until,
}

class RecurrenceRuleBuilder {
  RecurrenceRuleBuilder({
    required this.frequency,
    this.interval = 1,
    Set<int>? weeklyDays,
    this.monthlyDay,
    this.endType = RecurrenceEndType.never,
    this.count,
    this.until,
  }) : weeklyDays = weeklyDays ?? <int>{};

  final RecurrenceFrequency frequency;
  final int interval;
  final Set<int> weeklyDays;
  final int? monthlyDay;
  final RecurrenceEndType endType;
  final int? count;
  final DateTime? until;

  String? validate() {
    if (interval < 1) {
      return 'Interval must be greater than 0';
    }

    if (frequency == RecurrenceFrequency.weekly && weeklyDays.isEmpty) {
      return 'Select at least one weekday';
    }

    if (frequency == RecurrenceFrequency.monthly) {
      if (monthlyDay == null || monthlyDay! < 1 || monthlyDay! > 31) {
        return 'Monthly day must be in range 1..31';
      }
    }

    if (endType == RecurrenceEndType.count) {
      if (count == null || count! < 1) {
        return 'Count must be greater than 0';
      }
    }

    if (endType == RecurrenceEndType.until) {
      if (until == null) {
        return 'Until date is required';
      }
    }

    if (count != null && until != null) {
      return 'COUNT and UNTIL cannot be combined';
    }

    return null;
  }

  String toRRule() {
    final validationError = validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final parts = <String>['FREQ=${_toRRuleFrequency(frequency)}'];

    if (interval > 1) {
      parts.add('INTERVAL=$interval');
    }

    if (frequency == RecurrenceFrequency.weekly) {
      final sortedDays = weeklyDays.toList()..sort();
      final byDay = sortedDays.map(_weekdayToRRule).join(',');
      parts.add('BYDAY=$byDay');
    }

    if (frequency == RecurrenceFrequency.monthly) {
      parts.add('BYMONTHDAY=$monthlyDay');
    }

    if (endType == RecurrenceEndType.count) {
      parts.add('COUNT=$count');
    }

    if (endType == RecurrenceEndType.until && until != null) {
      parts.add('UNTIL=${_toUtcDateTime(until!)}');
    }

    return parts.join(';');
  }

  String _toUtcDateTime(DateTime value) {
    final utc = value.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    return '$year$month$day' 'T' '$hour$minute$second' 'Z';
  }

  String _toRRuleFrequency(RecurrenceFrequency value) {
    switch (value) {
      case RecurrenceFrequency.daily:
        return 'DAILY';
      case RecurrenceFrequency.weekly:
        return 'WEEKLY';
      case RecurrenceFrequency.monthly:
        return 'MONTHLY';
    }
  }

  String _weekdayToRRule(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MO';
      case DateTime.tuesday:
        return 'TU';
      case DateTime.wednesday:
        return 'WE';
      case DateTime.thursday:
        return 'TH';
      case DateTime.friday:
        return 'FR';
      case DateTime.saturday:
        return 'SA';
      case DateTime.sunday:
        return 'SU';
      default:
        throw ArgumentError('Unsupported weekday: $weekday');
    }
  }
}