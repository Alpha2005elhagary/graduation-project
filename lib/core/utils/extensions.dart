import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

extension StringX on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DateTimeX on DateTime {
  String toArDate() {
    return DateFormat.yMMMMd('ar').format(this);
  }

  String toArTime() {
    return DateFormat.Hm('ar').format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day;
  }
}

bool isArabic(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ar';
}
