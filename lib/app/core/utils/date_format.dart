import 'package:intl/intl.dart';

final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
final timestampFormat = DateFormat("MMMM, d, yyyy h:mm a");
final dateReportFormat = DateFormat("MMMM_y");

(DateTime startOfMonth, DateTime endOfMonth) getStartEndOfMonth(DateTime date) {
  final startDate = DateTime(date.year, date.month, 1);
  final lastDayofMonth = DateTime(date.year, date.month + 1, 0).day;
  final endDate = DateTime(date.year, date.month, lastDayofMonth, 23, 59, 59);
  return (startDate, endDate);
}
