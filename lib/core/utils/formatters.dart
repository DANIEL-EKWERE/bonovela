class Fmt {
  /// 1234 → 1.2K, 2400000 → 2.4M
  static String compact(int n) {
    if (n >= 1000000) return '${_trim(n / 1000000)}M';
    if (n >= 1000) return '${_trim(n / 1000)}K';
    return '$n';
  }

  static String _trim(double v) =>
      v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  static String views(int n) => '${compact(n)} Views';

  /// "just now", "10 minutes ago", "2 days ago", then a date.
  static String ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} minutes ago';
    if (d.inHours < 24) return '${d.inHours} hours ago';
    if (d.inDays < 30) return '${d.inDays} days ago';
    return date(t);
  }

  static String date(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
}
