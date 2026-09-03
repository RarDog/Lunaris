import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';

final viewedControllerProvider =
    AsyncNotifierProvider<ViewedController, List<ViewedTimelineGroup>>(
  ViewedController.new,
);

class ViewedController extends AsyncNotifier<List<ViewedTimelineGroup>> {
  @override
  Future<List<ViewedTimelineGroup>> build() => _load();

  Future<void> refresh() async {
    state = AsyncData(await _load());
  }

  Future<void> clear() async {
    await ref.read(viewedHistoryServiceProvider).clearHistory();
    ref.invalidate(viewedKeysProvider);
    state = const AsyncData([]);
  }

  Future<List<ViewedTimelineGroup>> _load() async {
    final result =
        await ref.read(viewedHistoryServiceProvider).getViewedPostEntries();
    if (result is! Success<List<ViewedPostEntry>>) return const [];
    return groupViewedTimeline(result.data);
  }
}

class ViewedTimelineGroup {
  const ViewedTimelineGroup({required this.label, required this.items});

  final String label;
  final List<ViewedPostEntry> items;
}

List<ViewedTimelineGroup> groupViewedTimeline(
  List<ViewedPostEntry> entries, {
  DateTime? now,
}) {
  final today = DateTime(now?.year ?? DateTime.now().year,
      now?.month ?? DateTime.now().month, now?.day ?? DateTime.now().day);
  final buckets = <String, List<ViewedPostEntry>>{};
  for (final entry in entries) {
    final date =
        DateTime(entry.viewedAt.year, entry.viewedAt.month, entry.viewedAt.day);
    final days = today.difference(date).inDays;
    final label = switch (days) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => _dateLabel(date),
    };
    buckets.putIfAbsent(label, () => []).add(entry);
  }
  return [
    for (final entry in buckets.entries)
      ViewedTimelineGroup(label: entry.key, items: entry.value),
  ];
}

String _dateLabel(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
