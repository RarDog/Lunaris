import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../backend/backend.dart';
import '../features/artists/presentation/artist_posts_screen.dart';
import '../features/artists/presentation/artists_screen.dart';
import '../features/collections/presentation/collection_details_screen.dart';
import '../features/collections/presentation/collections_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/feed/presentation/feed_screen.dart';
import '../features/post/presentation/post_details_screen.dart';
import '../features/post/presentation/similar_posts_screen.dart';
import '../features/providers/presentation/provider_check_screen.dart';
import '../features/providers/presentation/provider_form_screen.dart';
import '../features/providers/presentation/providers_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/cache_manager_screen.dart';
import '../features/settings/presentation/hidden_posts_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/viewed/presentation/viewed_screen.dart';
import '../shared/widgets/app_shell.dart';

final branchNavKeys = List.generate(8, (_) => GlobalKey<NavigatorState>());

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
          child: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: branchNavKeys[0],
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => _transitionPage(
                  state,
                  child: FeedScreen(initialQuery: state.uri.queryParameters['q']),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchNavKeys[1],
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchNavKeys[2],
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchNavKeys[3],
            routes: [
              GoRoute(
                path: '/viewed',
                builder: (context, state) => const ViewedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchNavKeys[4],
            routes: [
              GoRoute(
                path: '/collections',
                builder: (context, state) => const CollectionsScreen(),
                routes: [
                  GoRoute(
                    path: ':collectionId',
                    builder: (context, state) => CollectionDetailsScreen(
                      collectionId: state.pathParameters['collectionId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchNavKeys[5],
            routes: [
              GoRoute(
                path: '/artists',
                builder: (context, state) => const ArtistsScreen(),
                routes: [
                  GoRoute(
                    path: ':providerId/:service/:artistId',
                    builder: (context, state) => ArtistPostsScreen(
                      providerId: state.pathParameters['providerId']!,
                      service: state.pathParameters['service']!,
                      artistId: state.pathParameters['artistId']!,
                      artistName: state.uri.queryParameters['name'] ??
                          state.pathParameters['artistId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchNavKeys[6],
            routes: [
              GoRoute(
                path: '/providers',
                builder: (context, state) => const ProvidersScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => ProviderFormScreen(
                      initialConfig: state.extra is ContentProviderConfig
                          ? state.extra! as ContentProviderConfig
                          : null,
                    ),
                  ),
                  GoRoute(
                    path: 'check',
                    builder: (context, state) => const ProviderCheckScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchNavKeys[7],
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'hidden',
                    builder: (context, state) => const HiddenPostsScreen(),
                  ),
                  GoRoute(
                    path: 'cache',
                    builder: (context, state) => const CacheManagerScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/post/:providerId/:postId',
        builder: (context, state) {
          final extra = state.extra;
          final Post? initialPost;
          final List<Post>? postsList;
          if (extra is PostNavigationContext) {
            initialPost = extra.currentPost;
            postsList = extra.posts;
          } else if (extra is Post) {
            initialPost = extra;
            postsList = null;
          } else {
            initialPost = null;
            postsList = null;
          }
          return PostDetailsScreen(
            providerId: state.pathParameters['providerId']!,
            postId: state.pathParameters['postId']!,
            initialPost: initialPost,
            postsList: postsList,
          );
        },
        routes: [
          GoRoute(
            path: 'similar',
            builder: (context, state) => SimilarPostsScreen(
              providerId: state.pathParameters['providerId']!,
              postId: state.pathParameters['postId']!,
              initialPost: state.extra is Post ? state.extra! as Post : null,
            ),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _transitionPage(
  GoRouterState state, {
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 140),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.015, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}
