import 'package:intl/intl.dart';

class DateUtilsApp {
  DateUtilsApp._();

  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'es');
  static final _dateFormat = DateFormat('dd/MM/yyyy', 'es');
  static final _timeFormat = DateFormat('HH:mm', 'es');

  static String formatDateTime(DateTime dateTime) =>
      _dateTimeFormat.format(dateTime.toLocal());

  static String formatDate(DateTime dateTime) =>
      _dateFormat.format(dateTime.toLocal());

  static String formatTime(DateTime dateTime) =>
      _timeFormat.format(dateTime.toLocal());

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
