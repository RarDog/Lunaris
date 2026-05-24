import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/error_view.dart';
import 'search_controller.dart';
import 'widgets/recent_searches.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchControllerProvider);
    return AdaptiveScaffold(
      title: 'Search',
      actions: [
        IconButton(
          tooltip: 'Clear history',
          onPressed: () =>
              ref.read(searchControllerProvider.notifier).clearHistory(),
          icon: const Icon(Icons.delete_sweep_rounded),
        ),
      ],
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TagInputSearchBar(
              initialValue: data.query,
              suggestions: data.suggestions,
              onSubmitted: (query) =>
                  context.go('/?q=${Uri.encodeQueryComponent(query)}'),
              onChanged: (query) => ref
                  .read(searchControllerProvider.notifier)
                  .updateQuery(query),
              onSuggestionApplied: (query) => ref
                  .read(searchControllerProvider.notifier)
                  .updateQuery(query),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            Text('Recent', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            RecentSearches(
              items: data.recent,
              onTap: (query) =>
                  context.go('/?q=${Uri.encodeQueryComponent(query)}'),
            ),
          ],
        ),
      ),
    );
  }
}
