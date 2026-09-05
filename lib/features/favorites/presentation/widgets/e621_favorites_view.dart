import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_navigator.dart';
import '../../../../app/responsive.dart';
import '../../../../backend/backend.dart';
import '../../../../backend/providers/e621_provider.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/post_masonry_grid.dart';
import '../../../providers/presentation/providers_controller.dart';
import '../../../providers/presentation/widgets/e621_auth_dialog.dart';
import '../favorites_controller.dart';

class E621FavoritesView extends ConsumerStatefulWidget {
  const E621FavoritesView({
    required this.settings,
    required this.isRu,
    super.key,
  });

  final AppSettings settings;
  final bool isRu;

  @override
  ConsumerState<E621FavoritesView> createState() => _E621FavoritesViewState();
}

class _E621FavoritesViewState extends ConsumerState<E621FavoritesView> {
  final List<Post> _posts = [];
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  String? _currentLogin;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoading &&
        _hasMore) {
      _loadNextPage();
    }
  }

  Future<E621Provider?> _getE621Provider() async {
    final instance = await ref
        .read(providerManagerProvider)
        .getProviderInstance('e621');
    return instance is E621Provider ? instance : null;
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _posts.clear();
      _page = 1;
      _hasMore = true;
    });

    try {
      final provider = await _getE621Provider();
      if (provider == null) {
        setState(() {
          _isLoading = false;
          _error = widget.isRu
              ? 'Источник e621 не найден'
              : 'e621 provider not found';
        });
        return;
      }

      final login = provider.login?.trim();
      setState(() => _currentLogin = login);

      if (login == null || login.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final items = await provider.getFavorites(page: 1, limit: 50);
      if (mounted) {
        setState(() {
          _posts.addAll(items);
          _isLoading = false;
          _hasMore = items.length >= 25;
          _page = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = widget.isRu ? 'Ошибка загрузки: $e' : 'Loading error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final provider = await _getE621Provider();
      if (provider == null) {
        setState(() => _isLoading = false);
        return;
      }

      final items = await provider.getFavorites(page: _page, limit: 50);
      if (mounted) {
        setState(() {
          final existingIds = _posts.map((p) => p.id).toSet();
          final newItems =
              items.where((p) => !existingIds.contains(p.id)).toList();
          _posts.addAll(newItems);
          _isLoading = false;
          _hasMore = items.length >= 25;
          _page++;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importAllToLocal() async {
    if (_posts.isEmpty || _isImporting) return;
    setState(() => _isImporting = true);
    HapticFeedback.mediumImpact();

    final favService = ref.read(favoriteServiceProvider);
    int imported = 0;
    for (final post in _posts) {
      await favService.addFavorite(post);
      imported++;
    }

    ref.invalidate(favoriteKeysProvider);
    ref.invalidate(favoritesControllerProvider);

    if (mounted) {
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isRu
                ? 'Импортировано $imported постов в локальное избранное!'
                : 'Imported $imported posts to local favorites!',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final downloaded = ref.watch(
          downloadedMediaByKeysProvider(
            _posts.map((post) => post.cacheKey).toList(growable: false),
          ),
        ).value ??
        const <String, DownloadedMedia>{};

    final favoriteKeys = ref.watch(favoriteKeysProvider).value ?? <String>{};

    // If no login is set
    if (_currentLogin == null || _currentLogin!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0055AA), Color(0xFF0088FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0055AA).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  size: 34,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.isRu ? 'Аккаунт e621 не указан' : 'e621 account not set',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Text(
                  widget.isRu
                      ? 'Чтобы смотреть избранное (своё или друга) прямо здесь, укажите логин и API-ключ в настройках источника e621.'
                      : 'To browse favorites directly here, provide your e621 login and API key.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () async {
                  final configs =
                      ref.read(providersControllerProvider).value ?? [];
                  final e621Config = configs.firstWhere(
                    (p) => p.apiType.toLowerCase() == 'e621',
                    orElse: () => configs.first,
                  );
                  await E621AuthDialog.show(
                    context,
                    config: e621Config,
                    onSaved: (updated) {
                      ref
                          .read(providersControllerProvider.notifier)
                          .save(updated);
                      _loadInitial();
                    },
                  );
                },
                icon: const Icon(Icons.vpn_key_rounded, size: 18),
                label: Text(
                  widget.isRu
                      ? 'Войти / Настроить API-ключ e621'
                      : 'Set e621 API Key',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0055AA),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: Column(
        children: [
          // Header Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131A26).withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0055AA).withValues(alpha: 0.35)
                          : const Color(0xFF0055AA).withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0055AA), Color(0xFF0077EE)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Избранное: @$_currentLogin',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.isRu
                                  ? '${_posts.length} постов на сервере e621'
                                  : '${_posts.length} posts on e621',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_posts.isNotEmpty)
                        IconButton.filledTonal(
                          tooltip: widget.isRu
                              ? 'Импортировать в локальное избранное'
                              : 'Import to local favorites',
                          onPressed: _isImporting ? null : _importAllToLocal,
                          icon: _isImporting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.download_rounded, size: 18),
                        ),
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        tooltip: widget.isRu ? 'Обновить' : 'Refresh',
                        onPressed: _isLoading ? null : _loadInitial,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading && _posts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 40, color: Color(0xFFEF4444)),
                            const SizedBox(height: 12),
                            Text(_error!),
                            const SizedBox(height: 12),
                            FilledButton.tonal(
                              onPressed: _loadInitial,
                              child: Text(widget.isRu ? 'Повторить' : 'Retry'),
                            ),
                          ],
                        ),
                      )
                    : _posts.isEmpty
                        ? Center(
                            child: EmptyView(
                              title: widget.isRu
                                  ? 'У пользователя нет избранных постов'
                                  : 'No favorite posts for this user',
                            ),
                          )
                        : ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            children: [
                              PostMasonryGrid(
                                posts: _posts,
                                columns: Responsive.columnsFor(
                                  context,
                                  mobileColumns: widget.settings.mobileColumns,
                                  desktopColumns:
                                      widget.settings.desktopColumns,
                                ),
                                blurExplicit:
                                    widget.settings.blurExplicitContent,
                                showBadges: widget.settings.showPostBadges,
                                nsfwEnabled: widget.settings.nsfwEnabled,
                                mediaQualityMode: MediaQualityMode.fromName(
                                  widget.settings.mediaQualityMode,
                                ),
                                favoriteKeys: favoriteKeys,
                                downloadedKeys: downloaded.keys.toSet(),
                                onOpen: (post) => AppNavigator.openPost(
                                  context,
                                  post: post,
                                  postsList: _posts,
                                ),
                                onFavorite: (post) async {
                                  final isFav =
                                      favoriteKeys.contains(post.cacheKey);
                                  final favService =
                                      ref.read(favoriteServiceProvider);
                                  if (isFav) {
                                    await favService.removeFavorite(
                                        post.id, post.providerId);
                                  } else {
                                    await favService.addFavorite(post);
                                  }
                                  ref.invalidate(favoriteKeysProvider);
                                  ref.invalidate(favoritesControllerProvider);
                                },
                              ),
                              if (_isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
