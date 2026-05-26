import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/post_masonry_grid.dart';
import '../../favorites/presentation/favorites_controller.dart';

final artistPostsProvider =
    FutureProvider.family<List<Post>, ArtistWorkQuery>((ref, query) async {
  final providers =
      await ref.watch(providerManagerProvider).activeArtistProviders();
  if (providers is! Success<List<ArtistProvider>>) return const [];
  final provider = providers.data.firstWhere(
    (item) => (item as ContentProvider).id == query.providerId,
  );
  final posts = await provider.getArtistPosts(query: query, limit: 50);
  await ref.read(cacheServiceProvider).cachePosts(posts);
  return posts;
});

class ArtistPostsScreen extends ConsumerWidget {
  const ArtistPostsScreen({
    required this.providerId,
    required this.service,
    required this.artistId,
    required this.artistName,
    super.key,
  });

  final String providerId;
  final String service;
  final String artistId;
  final String artistName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ArtistWorkQuery(
      providerId: providerId,
      service: service,
      artistId: artistId,
      artistName: artistName,
    );
    final posts = ref.watch(artistPostsProvider(query));
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};
    final viewedKeys = ref.watch(viewedKeysProvider).value ?? <String>{};
    return AdaptiveScaffold(
      title: artistName,
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => ref.invalidate(artistPostsProvider(query)),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: _friendlyArtistPostError(error),
          onRetry: () => ref.invalidate(artistPostsProvider(query)),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(
                title: 'No works',
                message: 'This artist has no visible media yet.',
              )
            : PostMasonryGrid(
                posts: items,
                columns: Responsive.columnsFor(
                  context,
                  mobileColumns: settings.mobileColumns,
                  desktopColumns: settings.desktopColumns,
                ),
                blurExplicit: settings.blurExplicitContent,
                showBadges: settings.showPostBadges,
                nsfwEnabled: settings.nsfwEnabled,
                mediaQualityMode:
                    MediaQualityMode.fromName(settings.mediaQualityMode),
                favoriteKeys: favoriteKeys,
                viewedKeys: viewedKeys,
                onOpen: (post) => context.push(
                  '/post/${post.providerId}/${post.id}',
                  extra: post,
                ),
                onFavorite: (post) async {
                  if (favoriteKeys.contains(post.cacheKey)) {
                    await ref
                        .read(favoriteServiceProvider)
                        .removeFavorite(post.id, post.providerId);
                  } else {
                    await ref.read(favoriteServiceProvider).addFavorite(
                          post,
                          settings: settings,
                          downloadManager:
                              ref.read(downloadManagerServiceProvider),
                        );
                  }
                  ref.invalidate(favoriteKeysProvider);
                  ref.invalidate(favoritesControllerProvider);
                },
              ),
      ),
    );
  }

  String _friendlyArtistPostError(Object error) {
    final message = error.toString();
    if (message.contains('HandshakeException') ||
        message.contains('artist works are unavailable')) {
      return 'Artist works are unavailable from this provider right now. Try again later or choose another artist/provider.';
    }
    return message;
  }
}
