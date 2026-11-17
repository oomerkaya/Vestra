/// Exchange closures, loaded from `assets/data/market_holidays.json` so the
/// list can be updated without code changes.
class MarketCalendar {
  MarketCalendar({
    Iterable<DateTime> closedDays = const [],
    Iterable<DateTime> halfDays = const [],
  }) : _closed = closedDays.map(_key).toSet(),
       _half = halfDays.map(_key).toSet();

  /// Parses the asset JSON (`closed` and `half_days` as `YYYY-MM-DD`).
  factory MarketCalendar.fromJson(Map<String, dynamic> json) {
    List<DateTime> dates(String field) => [
      for (final value in (json[field] as List<dynamic>? ?? const []))
        DateTime.parse(value as String),
    ];
    return MarketCalendar(
      closedDays: dates('closed'),
      halfDays: dates('half_days'),
    );
  }

  static final empty = MarketCalendar();

  final Set<int> _closed;
  final Set<int> _half;

  /// [day] is an Istanbul wall-clock date; only Y/M/D are used.
  bool isClosed(DateTime day) => _closed.contains(_key(day));

  bool isHalfDay(DateTime day) => _half.contains(_key(day));

  static int _key(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
}
