import 'package:intl/intl.dart';

enum DateTimeFormat {
  ptBrCalendar("dd/MM/yyyy"),
  ptBrFull("d 'de' MMMM 'de' y"),
  onlyHoursAndMinutes("HH:mm"),
  yyyyMMdd("yyyy-MM-dd");

  final String format;

  const DateTimeFormat(this.format);
}

extension DateTimeExtensions on DateTime {
  String format([DateTimeFormat format = DateTimeFormat.ptBrCalendar, String prefix = ""]) {
    Intl.defaultLocale = 'pt_BR';
    return "$prefix${DateFormat(format.format).format(toLocal())}";
  }

  String formatDateRelativeToNow() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));

    final inputDate = DateTime(year, month, day);

    if (inputDate == today) {
      return "Hoje";
    } else if (inputDate == yesterday) {
      return "Ontem";
    } else if (inputDate == dayBeforeYesterday) {
      return "Anteontem";
    } else {
      final difference = today.difference(inputDate).inDays;
      return "Há $difference dias";
    }
  }

  String formatTime() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return "às $hour:$minute";
  }

  DateTime startOfDay() {
    return DateTime(year, month, day);
  }

  DateTime endOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}