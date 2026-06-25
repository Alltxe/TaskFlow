import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/l10n/app_localizations.dart';

String _localeOf(BuildContext context) => Localizations.localeOf(context).toString();

DateFormat localizedDateFormat(BuildContext context, String pattern) {
  return DateFormat(pattern, _localeOf(context));
}

String formatMonthDay(BuildContext context, DateTime date) {
  return localizedDateFormat(context, 'd MMM').format(date);
}

String formatMonthDayYear(BuildContext context, DateTime date) {
  return localizedDateFormat(context, 'd MMM y').format(date);
}

String formatMonthDayTime(BuildContext context, DateTime date) {
  return localizedDateFormat(context, 'd MMM, HH:mm').format(date);
}

String formatMonthDayYearTime(BuildContext context, DateTime date) {
  return localizedDateFormat(context, 'd MMM y, HH:mm').format(date);
}

String formatWeekRange(BuildContext context, DateTime start, DateTime end) {
  final sameYear = start.year == end.year;
  final startPattern = sameYear ? 'd MMM' : 'd MMM y';
  return '${localizedDateFormat(context, startPattern).format(start)} – '
      '${localizedDateFormat(context, 'd MMM y').format(end)}';
}

String formatTimeAgo(AppLocalizations l10n, DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) {
    return l10n.dateJustNow;
  }
  if (diff.inHours < 1) {
    return l10n.dateMinutesAgo(diff.inMinutes);
  }
  if (diff.inDays < 1) {
    return l10n.dateHoursAgo(diff.inHours);
  }
  if (diff.inDays < 7) {
    return l10n.dateDaysAgo(diff.inDays);
  }
  if (diff.inDays < 30) {
    return l10n.dateWeeksAgo((diff.inDays / 7).floor());
  }
  if (diff.inDays < 365) {
    return l10n.dateMonthsAgo((diff.inDays / 30).floor());
  }
  return l10n.dateYearsAgo((diff.inDays / 365).floor());
}
