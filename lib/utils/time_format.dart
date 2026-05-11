/// Helpers de formatage de durée.
///
/// `formatMinutes(95)` → "1h 35m"
/// `formatMinutes(58)` → "58m"
/// `formatMinutes(120)` → "2h"
String formatMinutes(int totalMin) {
  if (totalMin <= 0) return '0m';
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

/// `formatMMSS(125)` → "02:05"
String formatMMSS(int totalSec) {
  final m = (totalSec ~/ 60).toString().padLeft(2, '0');
  final s = (totalSec % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
