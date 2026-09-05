import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../app/app_navigator.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import 'settings_controller.dart';

final hiddenPostRowsProvider = FutureProvider<List<HiddenPostRow>>((ref) async {
  final settings = ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
  final repository = ref.watch(postRepositoryProvider);
  final rows = <HiddenPostRow>[];
  for (final key in settings.hiddenPostKeys) {
    final parts = key.split(':');
    Post? post;
    if (parts.length >= 2) {
      final result = await repository.getCachedPost(
          parts.sublist(1).join(':'), parts.first);
      if (result is Success<Post?>) post = result.data;
    }
    rows.add(HiddenPostRow(cacheKey: key, post: post));
  }
  return rows;
});

class HiddenPostsScreen extends ConsumerWidget {
  const HiddenPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(hiddenPostRowsProvider);
    return AdaptiveScaffold(
      title: 'Hidden posts',
      actions: [
        IconButton(
          tooltip: 'Restore all',
          onPressed: rows.valueOrNull?.isEmpty ?? true
              ? null
              : () async {
                  await ref.read(settingsServiceProvider).clearHiddenPosts();
                  ref.invalidate(appSettingsProvider);
                  ref.invalidate(settingsControllerProvider);
                  ref.invalidate(hiddenPostRowsProvider);
                },
          icon: const Icon(Icons.restore_rounded),
        ),
      ],
      body: rows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No hidden posts'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _HiddenPostTile(
                    item: item,
                    onOpen: item.post == null
                        ? null
                        : () => AppNavigator.openPost(
                              context,
                              post: item.post!,
                            ),
                    onRestore: () async {
                      await ref
                          .read(settingsServiceProvider)
                          .unhidePostKey(item.cacheKey);
                      ref.invalidate(appSettingsProvider);
                      ref.invalidate(settingsControllerProvider);
                      ref.invalidate(hiddenPostRowsProvider);
                    },
                  );
                },
              ),
      ),
    );
  }
}

class HiddenPostRow {
  const HiddenPostRow({required this.cacheKey, this.post});

  final String cacheKey;
  final Post? post;
}

class _HiddenPostTile extends StatelessWidget {
  const _HiddenPostTile({
    required this.item,
    required this.onRestore,
    this.onOpen,
  });

  final HiddenPostRow item;
  final VoidCallback onRestore;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final post = item.post;
    final imageUrl =
        post == null ? null : MediaUrlSelector.preview(post).firstOrNull;
    return Card(
      child: ListTile(
        onTap: onOpen,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 56,
            height: 56,
            child: imageUrl == null
                ? const Icon(Icons.visibility_off_rounded)
                : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          ),
        ),
        title: Text(post?.tags.take(4).join(' ') ?? item.cacheKey),
        subtitle: Text(post?.providerName ?? item.cacheKey),
        trailing: TextButton(
          onPressed: onRestore,
          child: const Text('Restore'),
        ),
      ),
    );
  }
}
