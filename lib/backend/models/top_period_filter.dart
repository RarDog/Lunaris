enum TopPeriodFilter {
  none,
  month,
  year,
  allTime;

  String get label {
    return switch (this) {
      TopPeriodFilter.none => 'Latest',
      TopPeriodFilter.month => 'Top month',
      TopPeriodFilter.year => 'Top year',
      TopPeriodFilter.allTime => 'Top all time',
    };
  }
}
