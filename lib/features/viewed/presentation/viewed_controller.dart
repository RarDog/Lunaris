import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';

final viewedControllerProvider =
    AsyncNotifierProvider<ViewedController, List<Post>>(ViewedController.new);

class ViewedController extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() => _load();

  Future<void> refresh() async {
    state = AsyncData(await _load());
  }

  Future<void> clear() async {
    await ref.read(viewedHistoryServiceProvider).clearHistory();
    ref.invalidate(viewedKeysProvider);
    state = const AsyncData([]);
  }

  Future<List<Post>> _load() async {
    final result =
        await ref.read(viewedHistoryServiceProvider).getViewedPosts();
    return result is Success<List<Post>> ? result.data : const [];
  }
}
