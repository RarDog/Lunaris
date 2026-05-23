import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import 'collection_form_dialog.dart';
import 'collections_controller.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsControllerProvider);
    return AdaptiveScaffold(
      title: 'Collections',
      actions: [
        IconButton(
          tooltip: 'New collection',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => showCollectionFormDialog(context, ref),
        ),
      ],
      body: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (items) => items.isEmpty
            ? const EmptyView(title: 'No collections yet')
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.go('/collections/${item.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.collections_bookmark_rounded,
                                size: 32),
                            const Spacer(),
                            Text(item.name,
                                style: Theme.of(context).textTheme.titleLarge),
                            Text(item.description ?? ''),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () => showCollectionFormDialog(
                                    context,
                                    ref,
                                    collection: item,
                                  ),
                                  icon: const Icon(Icons.edit_rounded),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: () async {
                                    final ok = await showConfirmDialog(
                                      context,
                                      title: 'Delete collection',
                                      message: 'Remove ${item.name}?',
                                    );
                                    if (ok) {
                                      await ref
                                          .read(collectionsControllerProvider
                                              .notifier)
                                          .delete(item.id);
                                    }
                                  },
                                  icon: const Icon(Icons.delete_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
