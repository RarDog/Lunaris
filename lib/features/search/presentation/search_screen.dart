import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/error_view.dart';
import 'search_controller.dart';
import 'widgets/recent_searches.dart';
import 'widgets/search_suggestions.dart';

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
            AppSearchBar(
              onSubmitted: (query) =>
                  context.go('/?q=${Uri.encodeQueryComponent(query)}'),
              onChanged: (query) => ref
                  .read(searchControllerProvider.notifier)
                  .updateQuery(query),
            ),
            const SizedBox(height: 16),
            SearchSuggestions(
              suggestions: data.suggestions,
              onTap: (suggestion) {
                final query = _applySuggestion(data.query, suggestion);
                context.go('/?q=${Uri.encodeQueryComponent(query)}');
              },
            ),
            const SizedBox(height: 24),
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

  String _applySuggestion(String query, String suggestion) {
    final tokens =
        query.trim().isEmpty ? <String>[] : query.trim().split(RegExp(r'\s+'));
    if (tokens.isEmpty) {
      tokens.add(suggestion);
    } else {
      tokens[tokens.length - 1] = suggestion;
    }
    return tokens.toSet().join(' ');
  }
}
