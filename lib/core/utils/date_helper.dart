import 'package:intl/intl.dart';

class DateHelper {
  static String getHijriDate() {
    return getHijriDateFor(DateTime.now());
  }

  static String getHijriDateFor(DateTime date) {
    final julianDay = _gregorianToJulian(date.year, date.month, date.day);
    final hijri = _julianToHijri(julianDay);
    final monthNames = [
      'Muharram', 'Safar', 'Rabi\'ul Awwal', 'Rabi\'ul Akhir',
      'Jumadil Awwal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
      'Ramadhan', 'Syawal', 'Dzulqa\'dah', 'Dzulhijjah'
    ];
    return '${hijri[2]} ${monthNames[hijri[1] - 1]} ${hijri[0]} H';
  }

  static double _gregorianToJulian(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  static List<int> _julianToHijri(double jd) {
    final z = (jd + 0.5).floor();
    final a = z;
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();
    final day = b - d - (30.6001 * e).floor();
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;

    final l = z - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor() +
        (l2 / 5670).floor() * ((43 * l2) / 15238).floor();
    final l3 = l2 -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final m2 = (24 * l3) ~/ 709;
    final d2 = l3 - (709 * m2) ~/ 24;
    final y2 = 30 * n + j - 30;

    return [y2, m2, d2];
  }

  static String formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return timeStr;
    } catch (_) {
      return timeStr;
    }
  }

  static String getCountdown(String targetTime) {
    try {
      final now = DateTime.now();
      final parts = targetTime.split(':');
      if (parts.length < 2) return '00:00:00';
      final targetHour = int.parse(parts[0]);
      final targetMinute = int.parse(parts[1]);
      var target = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }
      final diff = target.difference(now);
      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (_) {
      return '00:00:00';
    }
  }

  static String todayFormatted() {
    return DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  static String getCurrentMonth() {
    return DateFormat('MMMM', 'id_ID').format(DateTime.now());
  }

  static int getCurrentYear() {
    return DateTime.now().year;
  }

  static int getCurrentMonthNumber() {
    return DateTime.now().month;
  }

  static String getDayName() {
    return DateFormat('EEEE', 'id_ID').format(DateTime.now());
  }
}
