import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/responsive.dart';
import '../../../backend/backend.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';

final artistProviderConfigsProvider =
    FutureProvider<List<ContentProviderConfig>>((ref) async {
  final result = await ref
      .watch(providerManagerProvider)
      .loadArtistConfigs(enabledOnly: true);
  return result is Success<List<ContentProviderConfig>>
      ? result.data
      : const [];
});

class ArtistsScreen extends ConsumerStatefulWidget {
  const ArtistsScreen({super.key});

  @override
  ConsumerState<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends ConsumerState<ArtistsScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  String? _providerId;
  var _page = 1;
  var _loading = false;
  var _hasMore = true;
  Object? _error;
  List<ArtistProfile> _artists = const [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 500) _loadMore();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(artistProviderConfigsProvider);
    return AdaptiveScaffold(
      title: 'Artists',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => _refresh(configs.valueOrNull ?? const []),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: configs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              title: 'No artist providers',
              message: 'Enable Kemono or Coomer in Providers.',
            );
          }
          _providerId ??= items.first.id;
          if (_artists.isEmpty && !_loading && _error == null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _refresh(items));
          }
          return Column(
            children: [
              _ArtistsHeader(
                searchController: _search,
                providers: items,
                selectedProviderId: _providerId,
                onProviderChanged: (value) {
                  setState(() => _providerId = value);
                  _refresh(items);
                },
                onSearch: () => _refresh(items),
              ),
              Expanded(
                child: _error != null
                    ? ErrorView(
                        message: _friendlyArtistError(_error),
                        onRetry: () => _refresh(items),
                      )
                    : _artists.isEmpty && !_loading
                        ? const EmptyView(
                            title: 'No artists',
                            message: 'Try another name or provider.',
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = Responsive.isMobile(context)
                                  ? 1
                                  : constraints.maxWidth >= 1100
                                      ? 3
                                      : constraints.maxWidth >= 760
                                          ? 2
                                          : 1;
                              return GridView.builder(
                                controller: _scroll,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 10, 16, 18),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent:
                                      Responsive.isMobile(context) ? 88 : 104,
                                ),
                                itemCount: _artists.length + (_loading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _artists.length) {
                                    return const _ArtistSkeletonCard();
                                  }
                                  final artist = _artists[index];
                                  return _ArtistCard(
                                    artist: artist,
                                    onTap: () => context.push(
                                      '/artists/${artist.providerId}/${artist.service}/${artist.id}?name=${Uri.encodeComponent(artist.displayName)}',
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _friendlyArtistError(Object? error) {
    final message = error.toString();
    if (message.contains('HandshakeException') ||
        message.contains('artist works are unavailable')) {
      return 'Artist API is unavailable right now. Try refresh or another provider.';
    }
    return message;
  }

  Future<void> _refresh(List<ContentProviderConfig> configs) async {
    if (configs.isEmpty) return;
    setState(() {
      _page = 1;
      _hasMore = true;
      _artists = const [];
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || _providerId == null) return;
    setState(() => _loading = true);
    try {
      final manager = ref.read(providerManagerProvider);
      final providers = await manager.activeArtistProviders();
      if (providers is! Success<List<ArtistProvider>>) return;
      final provider = providers.data.firstWhere(
        (item) => (item as ContentProvider).id == _providerId,
      );
      final next = await provider.searchArtists(
        _search.text.trim(),
        page: _page,
        limit: 30,
      );
      if (!mounted) return;
      setState(() {
        _artists = [..._artists, ...next];
        _page++;
        _hasMore = next.isNotEmpty;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _ArtistsHeader extends StatelessWidget {
  const _ArtistsHeader({
    required this.searchController,
    required this.providers,
    required this.selectedProviderId,
    required this.onProviderChanged,
    required this.onSearch,
  });

  final TextEditingController searchController;
  final List<ContentProviderConfig> providers;
  final String? selectedProviderId;
  final ValueChanged<String?> onProviderChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Search artists',
                        border: InputBorder.none,
                        filled: false,
                      ),
                      onSubmitted: (_) => onSearch(),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Search',
                    onPressed: onSearch,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return ChoiceChip(
                      selected: provider.id == selectedProviderId,
                      avatar: const Icon(Icons.person_search_rounded, size: 16),
                      label: Text(provider.name),
                      onSelected: (_) => onProviderChanged(provider.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({required this.artist, required this.onTap});

  final ArtistProfile artist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _ArtistAvatar(artist: artist),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MiniBadge(artist.service),
                        if (artist.postCount != null)
                          _MiniBadge('${artist.postCount} posts'),
                      ],
                    ),
                    if (artist.updatedAt != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Updated ${artist.updatedAt!.toLocal().toString().split('.').first}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtistAvatar extends StatelessWidget {
  const _ArtistAvatar({required this.artist});

  final ArtistProfile artist;

  @override
  Widget build(BuildContext context) {
    final name = artist.displayName.trim();
    final initials = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipOval(
        child: artist.avatarUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: artist.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _ArtistSkeletonCard extends StatelessWidget {
  const _ArtistSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
