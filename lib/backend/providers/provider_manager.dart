import 'dart:async';

import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../models/content_provider_config.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/provider_diagnostics.dart';
import '../models/provider_health.dart';
import '../models/tag_suggestion.dart';
import '../models/top_period_filter.dart';
import '../repositories/provider_repository.dart';
import 'content_provider.dart';
import 'provider_factory.dart';

class ProviderManager {
  ProviderManager(this._repository, this._factory);

  final ProviderRepository _repository;
  final ProviderFactory _factory;
  final Map<String, _SuggestionCacheEntry> _suggestionCache = {};
  final Set<String> _softRetryKeys = {};
  final _softRetryController =
      StreamController<ProviderSoftRetryResult>.broadcast();
  _SuggestionProviderCacheEntry? _suggestionProviderCache;

  static const _suggestionCacheTtl = Duration(seconds: 45);
  static const _suggestionProviderCacheTtl = Duration(seconds: 60);
  static const _suggestionTimeout = Duration(milliseconds: 1500);

  Stream<ProviderSoftRetryResult> get softRetryResults =>
      _softRetryController.stream;

  Future<Result<List<ContentProviderConfig>>> loadConfigs({
    bool enabledOnly = true,
  }) async {
    await _repository.ensureSeedProviders();
    final result = await _repository.getProviders(enabledOnly: enabledOnly);
    if (result is Error<List<ContentProviderConfig>>) return result;
    final configs = (result as Success<List<ContentProviderConfig>>)
        .data
        .where((config) => !_isLegacyRemovedConfig(config))
        .toList(growable: false);
    return Success(configs);
  }

  Future<Result<List<ContentProviderConfig>>> loadFeedConfigs({
    bool enabledOnly = true,
  }) async {
    final result = await loadConfigs(enabledOnly: enabledOnly);
    if (result is Error<List<ContentProviderConfig>>) {
      return Error(result.failure);
    }
    final configs = (result as Success<List<ContentProviderConfig>>)
        .data
        .where(_isFeedConfig)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return Success(configs);
  }

  Future<Result<List<ContentProviderConfig>>> loadArtistConfigs({
    bool enabledOnly = true,
  }) async {
    final result = await loadConfigs(enabledOnly: enabledOnly);
    if (result is Error<List<ContentProviderConfig>>) {
      return Error(result.failure);
    }
    final configs = (result as Success<List<ContentProviderConfig>>)
        .data
        .where(_isArtistConfig)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return Success(configs);
  }

  Future<Result<List<ContentProvider>>> activeProviders() async {
    final result = await loadConfigs();
    if (result is Error<List<ContentProviderConfig>>) {
      return Error(result.failure);
    }
    final configs = (result as Success<List<ContentProviderConfig>>).data
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return Success(configs.map(_factory.create).toList());
  }

  Future<Result<List<ContentProvider>>> activeFeedProviders() async {
    final result = await loadFeedConfigs();
    if (result is Error<List<ContentProviderConfig>>) {
      return Error(result.failure);
    }
    final configs = (result as Success<List<ContentProviderConfig>>).data;
    return Success(configs.map(_factory.create).toList());
  }

  Future<Result<List<ArtistProvider>>> activeArtistProviders() async {
    final result = await loadArtistConfigs();
    if (result is Error<List<ContentProviderConfig>>) {
      return Error(result.failure);
    }
    final configs = (result as Success<List<ContentProviderConfig>>).data;
    final providers = configs
        .map(_factory.create)
        .whereType<ArtistProvider>()
        .toList(growable: false);
    return Success(providers);
  }

  Future<Result<void>> enableProvider(String id, bool enabled) async {
    final result = await _repository.getProvider(id);
    return result.fold(
      onSuccess: (config) {
        if (config == null) {
          return const Error<void>(
            Failure(code: 'not_found', message: 'Provider not found'),
          );
        }
        return _repository
            .saveProvider(
          config.copyWith(enabled: enabled, updatedAt: DateTime.now()),
        )
            .then((result) {
          _clearSuggestionCaches();
          return result;
        });
      },
      onError: Error<void>.new,
    );
  }

  Future<Result<void>> addCustomProvider(ContentProviderConfig config) {
    return _repository
        .saveProvider(config.copyWith(updatedAt: DateTime.now()))
        .then((result) {
      _clearSuggestionCaches();
      return result;
    });
  }

  Future<Result<void>> deleteProvider(String id) {
    return _repository.deleteProvider(id).then((result) {
      _clearSuggestionCaches();
      return result;
    });
  }

  Future<ContentProvider?> getProviderInstance(String id) async {
    final result = await _repository.getProvider(id);
    if (result is Success<ContentProviderConfig?> && result.data != null) {
      return _factory.create(result.data!);
    }
    return null;
  }

  Future<Result<List<ProviderHealth>>> checkAll({int concurrency = 3}) async {
    final providersResult = await activeProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = (providersResult as Success<List<ContentProvider>>).data;
    if (providers.isEmpty) return const Success([]);
    final results = await _runLimited(
      providers,
      concurrency,
      (provider) async {
        final health = await provider.checkHealth();
        await _repository.saveHealth(health);
        return health;
      },
    );
    return Success(results);
  }

  static List<List<String>> splitTagGroups(List<String> rawTags) {
    final segments = <List<String>>[];
    List<String> current = [];

    for (final raw in rawTags) {
      var token = raw.trim();
      if (token.isEmpty) continue;

      // Only strip parentheses if they are grouping delimiters (unbalanced in the token, e.g. '(cat' or 'dog)')
      // but preserve tags that have internal paired parentheses like 'tyson_(password)'.
      if (token.startsWith('(') && !token.contains(')')) {
        token = token.substring(1).trim();
      }
      if (token.endsWith(')') && !token.contains('(')) {
        token = token.substring(0, token.length - 1).trim();
      }
      if (token.isEmpty) continue;

      if (token.toLowerCase() == 'and') {
        if (current.isNotEmpty) {
          segments.add(current);
          current = [];
        }
      } else {
        current.add(token);
      }
    }

    if (current.isNotEmpty) {
      segments.add(current);
    }

    if (segments.isEmpty) {
      return [const []];
    }

    if (segments.length == 1) {
      return segments;
    }

    // Multiple segments separated by 'and'
    // If the last segment has trailing tags after the branch tag (e.g. 'cat and dog anthro'):
    // The trailing tags apply as common modifier tags to ALL branches!
    final lastSegment = segments.last;
    final prevSegment = segments[segments.length - 2];
    final branchLen = prevSegment.length.clamp(1, lastSegment.length);

    if (lastSegment.length > branchLen) {
      final commonTail = lastSegment.sublist(branchLen);
      final adjustedSegments = <List<String>>[];

      for (int i = 0; i < segments.length; i++) {
        final seg = i == segments.length - 1
            ? lastSegment
            : [...segments[i], ...commonTail];

        final seen = <String>{};
        final deduped = <String>[];
        for (final t in seg) {
          if (seen.add(t.toLowerCase())) {
            deduped.add(t);
          }
        }
        adjustedSegments.add(deduped);
      }
      return adjustedSegments;
    }

    return segments;
  }

  Future<Result<List<Post>>> searchAcrossProviders({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    String? providerId,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    final providersResult = await activeFeedProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    var providers = (providersResult as Success<List<ContentProvider>>).data;
    if (providerId != null) {
      providers =
          providers.where((provider) => provider.id == providerId).toList();
    }

    final tagGroups = splitTagGroups(tags);

    if (tagGroups.length <= 1) {
      final effectiveTags = tagGroups.isEmpty ? tags : tagGroups.first;
      return _searchForTagGroup(
        providers: providers,
        tags: effectiveTags,
        page: page,
        limit: limit,
        rating: rating,
        providerId: providerId,
        topPeriod: topPeriod,
      );
    }

    // Multiple independent tag groups: query each tag group as if other tags are not present, then interleave
    final seen = <String>{};
    final groupPerLimit = (limit / tagGroups.length).ceil().clamp(10, 50);
    final groupFutures = tagGroups.map((groupTags) {
      return _searchForTagGroup(
        providers: providers,
        tags: groupTags,
        page: page,
        limit: groupPerLimit,
        rating: rating,
        providerId: providerId,
        topPeriod: topPeriod,
      );
    }).toList(growable: false);

    final results = await Future.wait(groupFutures);
    final validGroupPosts = <List<Post>>[];
    for (final res in results) {
      if (res is Success<List<Post>>) {
        validGroupPosts.add(res.data);
      }
    }

    final interleaved = _interleaveTagGroupResults(validGroupPosts, seen);
    return Success(interleaved);
  }

  Future<Result<List<Post>>> _searchForTagGroup({
    required List<ContentProvider> providers,
    required List<String> tags,
    required int page,
    required int limit,
    required String? rating,
    required String? providerId,
    required TopPeriodFilter topPeriod,
  }) async {
    final cleanTags = tags
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty && t.toLowerCase() != 'and')
        .toList(growable: false);

    final seen = <String>{};
    final providerResults = <List<Post>>[];
    for (final provider in providers) {
      try {
        final providerPosts = await provider.searchPosts(
          tags: cleanTags,
          page: page,
          limit: limit,
          rating: rating,
          topPeriod: topPeriod,
        );
        providerResults.add(providerPosts);
        await _repository.saveDiagnostics(
          ProviderDiagnostics(
            providerId: provider.id,
            lastSearchAt: DateTime.now(),
            lastResultCount: providerPosts.length,
          ),
        );
      } catch (_) {
        await _repository.saveDiagnostics(
          ProviderDiagnostics(
            providerId: provider.id,
            lastSearchAt: DateTime.now(),
            lastResultCount: 0,
            lastErrorMessage: 'Search failed',
          ),
        );
        await _repository.saveHealth(
          ProviderHealth(
            providerId: provider.id,
            status: ProviderStatus.offline,
            pingMs: 0,
            lastCheckedAt: DateTime.now(),
            errorMessage: 'Search failed',
          ),
        );
        _scheduleSoftSearchRetry(
          provider,
          tags: tags,
          page: page,
          limit: limit,
          rating: rating,
          topPeriod: topPeriod,
        );
      }
    }
    final posts = providerId == null
        ? _interleaveProviderResults(providerResults, seen)
        : _flattenProviderResults(providerResults, seen);
    return Success(posts);
  }

  List<Post> _interleaveTagGroupResults(
      List<List<Post>> groupResults, Set<String> seen) {
    final combined = <Post>[];
    var hasMore = true;
    var index = 0;

    while (hasMore) {
      hasMore = false;
      for (final group in groupResults) {
        if (index < group.length) {
          hasMore = true;
          final post = group[index];
          if (seen.add(post.cacheKey)) {
            combined.add(post);
          }
        }
      }
      index++;
    }

    return combined;
  }

  List<Post> _flattenProviderResults(
      List<List<Post>> results, Set<String> seen) {
    final posts = <Post>[];
    for (final providerPosts in results) {
      for (final post in providerPosts) {
        if (seen.add(post.cacheKey)) posts.add(post);
      }
    }
    return posts;
  }

  List<Post> _interleaveProviderResults(
    List<List<Post>> results,
    Set<String> seen,
  ) {
    final posts = <Post>[];
    for (final providerPosts in results) {
      for (final post in providerPosts) {
        if (seen.add(post.cacheKey)) posts.add(post);
      }
    }
    posts.sort((a, b) => _mixKey(a).compareTo(_mixKey(b)));
    return posts;
  }

  int _mixKey(Post post) {
    var hash = 0x811c9dc5;
    for (final code in post.cacheKey.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  void _scheduleSoftSearchRetry(
    ContentProvider provider, {
    required List<String> tags,
    required int page,
    required int limit,
    required String? rating,
    required TopPeriodFilter topPeriod,
  }) {
    final key = [
      provider.id,
      page,
      limit,
      rating ?? '',
      topPeriod.name,
      ...tags,
    ].join('\u001f');
    if (!_softRetryKeys.add(key)) return;
    unawaited(Future<void>.delayed(const Duration(milliseconds: 900), () async {
      try {
        final posts = await provider.searchPosts(
          tags: tags,
          page: page,
          limit: limit,
          rating: rating,
          topPeriod: topPeriod,
        );
        await _repository.saveDiagnostics(
          ProviderDiagnostics(
            providerId: provider.id,
            lastSearchAt: DateTime.now(),
            lastResultCount: posts.length,
          ),
        );
        await _repository.saveHealth(
          ProviderHealth(
            providerId: provider.id,
            status: ProviderStatus.online,
            pingMs: 0,
            lastCheckedAt: DateTime.now(),
          ),
        );
        if (posts.isNotEmpty) {
          _softRetryController.add(
            ProviderSoftRetryResult(
              providerId: provider.id,
              tags: tags,
              page: page,
              limit: limit,
              rating: rating,
              topPeriod: topPeriod,
              posts: posts,
            ),
          );
        }
      } catch (_) {
        await _repository.saveDiagnostics(
          ProviderDiagnostics(
            providerId: provider.id,
            lastSearchAt: DateTime.now(),
            lastResultCount: 0,
            lastErrorMessage: 'Search failed after retry',
          ),
        );
      } finally {
        _softRetryKeys.remove(key);
      }
    }));
  }

  Future<Result<List<PostComment>>> getComments(
    String providerId,
    String postId,
  ) async {
    final providersResult = await activeProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = (providersResult as Success<List<ContentProvider>>).data;
    final matches = providers.where((provider) => provider.id == providerId);
    if (matches.isEmpty) {
      return const Error(
        Failure(code: 'not_found', message: 'Provider not found'),
      );
    }
    final provider = matches.first;
    if (provider is! CommentProvider) return const Success([]);
    try {
      return Success(await (provider as CommentProvider).getComments(postId));
    } catch (error) {
      return Error(
        Failure(
          code: 'comments_unavailable',
          message: 'Comments unavailable',
          details: error,
        ),
      );
    }
  }

  Future<Result<Post?>> getPost(String providerId, String postId) async {
    final providersResult = await activeProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = (providersResult as Success<List<ContentProvider>>).data;
    final matches = providers.where((provider) => provider.id == providerId);
    if (matches.isEmpty) {
      return const Error(
          Failure(code: 'not_found', message: 'Provider not found'));
    }
    try {
      return Success(await matches.first.getPost(postId));
    } catch (error) {
      return Error(
        Failure(
          code: 'provider_get_post',
          message: 'Could not load post',
          details: error,
        ),
      );
    }
  }

  Future<Result<String?>> getPostPageUrl(Post post) async {
    final providersResult = await activeProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = (providersResult as Success<List<ContentProvider>>).data;
    final matches =
        providers.where((provider) => provider.id == post.providerId);
    if (matches.isEmpty || matches.first is! PostPageProvider) {
      return const Success(null);
    }
    return Success((matches.first as PostPageProvider).postPageUrl(post));
  }

  Future<Result<Map<String, String>>> getMediaHeaders(Post post) async {
    final providersResult = await activeProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = (providersResult as Success<List<ContentProvider>>).data;
    final matches =
        providers.where((provider) => provider.id == post.providerId);
    if (matches.isNotEmpty && matches.first is MediaHeadersProvider) {
      return Success(
        (matches.first as MediaHeadersProvider).mediaHeaders(post),
      );
    }
    return const Success({
      'User-Agent': 'Prisma/2.0.1 Flutter local booru browser',
      'Accept': '*/*',
    });
  }

  Future<Result<Post>> enrichPostTags(Post post) async {
    final hasUsefulGroups = post.tagGroups.entries.any(
      (entry) => entry.key != 'general' && entry.value.isNotEmpty,
    );
    if (hasUsefulGroups || post.tags.isEmpty) return Success(post);

    final providersResult = await activeFeedProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = (providersResult as Success<List<ContentProvider>>).data;
    final matches =
        providers.where((provider) => provider.id == post.providerId);
    if (matches.isEmpty || matches.first is! TagMetadataProvider) {
      return Success(post);
    }

    try {
      final groups = await (matches.first as TagMetadataProvider)
          .categorizeTags(post.tags);
      if (groups.isEmpty) return Success(post);
      return Success(post.copyWith(tagGroups: groups));
    } catch (error) {
      return Success(post);
    }
  }

  Future<Result<List<TagSuggestion>>> suggestTags(
    String query, {
    int limit = 20,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const Success([]);
    final providersResult = await activeSuggestionProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = (providersResult as Success<List<ContentProvider>>).data;
    if (providers.isEmpty) return const Success([]);

    final cappedLimit = limit.clamp(1, 50);
    final providerIds = providers.map((provider) => provider.id).join(',');
    final cacheKey = '$normalizedQuery|$providerIds|$cappedLimit';
    final cached = _suggestionCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.createdAt) < _suggestionCacheTtl) {
      return Success(cached.items.take(cappedLimit).toList(growable: false));
    }

    final providerResults = await Future.wait(
      providers.map(
        (provider) => _suggestionsFromProvider(
          provider as TagSuggestionProvider,
          normalizedQuery,
          cappedLimit,
        ),
      ),
    );
    final suggestions = <String, TagSuggestion>{};
    for (final items in providerResults) {
      for (final item in items) {
        final nameKey = item.name.trim().toLowerCase();
        if (nameKey.isEmpty) continue;
        final current = suggestions[nameKey];
        if (current == null || item.postCount > current.postCount) {
          suggestions[nameKey] = item;
        }
      }
    }
    final values = suggestions.values.toList()
      ..sort((a, b) {
        final count = b.postCount.compareTo(a.postCount);
        return count != 0 ? count : a.name.compareTo(b.name);
      });
    _suggestionCache[cacheKey] = _SuggestionCacheEntry(
      DateTime.now(),
      values,
    );
    _pruneSuggestionCache();
    return Success(values.take(cappedLimit).toList());
  }

  Future<List<TagSuggestion>> _suggestionsFromProvider(
    TagSuggestionProvider provider,
    String query,
    int limit,
  ) async {
    try {
      return await provider
          .suggestTags(query, limit: limit)
          .timeout(_suggestionTimeout);
    } catch (_) {
      // Suggestions are non-critical; a failed provider should not affect UI.
      return const [];
    }
  }

  void _pruneSuggestionCache() {
    final now = DateTime.now();
    _suggestionCache.removeWhere(
      (_, entry) => now.difference(entry.createdAt) >= _suggestionCacheTtl,
    );
  }

  Future<Result<List<ContentProvider>>> activeSuggestionProviders() async {
    final cached = _suggestionProviderCache;
    if (cached != null &&
        DateTime.now().difference(cached.createdAt) <
            _suggestionProviderCacheTtl) {
      return Success(cached.providers);
    }

    final providersResult = await activeFeedProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = <ContentProvider>[
      for (final provider
          in (providersResult as Success<List<ContentProvider>>).data)
        if (provider is TagSuggestionProvider) provider,
    ];
    _suggestionProviderCache = _SuggestionProviderCacheEntry(
      DateTime.now(),
      providers,
    );
    return Success(providers);
  }

  void _clearSuggestionCaches() {
    _suggestionCache.clear();
    _suggestionProviderCache = null;
  }

  Future<List<R>> _runLimited<T, R>(
    List<T> items,
    int concurrency,
    Future<R> Function(T item) action,
  ) async {
    final results = <R>[];
    var index = 0;

    Future<void> worker() async {
      while (index < items.length) {
        final current = items[index++];
        results.add(await action(current));
      }
    }

    await Future.wait(
      List.generate(concurrency.clamp(1, items.length), (_) => worker()),
    );
    return results;
  }

  static bool _isArtistConfig(ContentProviderConfig config) {
    final type = config.apiType.toLowerCase();
    return type == 'pawchive';
  }

  static bool _isFeedConfig(ContentProviderConfig config) {
    final type = config.apiType.toLowerCase();
    return type != 'pawchive';
  }

  static bool _isLegacyRemovedConfig(ContentProviderConfig config) {
    final id = config.id.toLowerCase();
    final type = config.apiType.toLowerCase();
    return id == 'cosbooru' ||
        type == 'realbooru' ||
        type == 'kemono' ||
        type == 'coomer' ||
        id == 'kemono' ||
        id == 'coomer';
  }
}

class _SuggestionCacheEntry {
  const _SuggestionCacheEntry(this.createdAt, this.items);

  final DateTime createdAt;
  final List<TagSuggestion> items;
}

class _SuggestionProviderCacheEntry {
  const _SuggestionProviderCacheEntry(this.createdAt, this.providers);

  final DateTime createdAt;
  final List<ContentProvider> providers;
}

class ProviderSoftRetryResult {
  const ProviderSoftRetryResult({
    required this.providerId,
    required this.tags,
    required this.page,
    required this.limit,
    required this.topPeriod,
    required this.posts,
    this.rating,
  });

  final String providerId;
  final List<String> tags;
  final int page;
  final int limit;
  final TopPeriodFilter topPeriod;
  final String? rating;
  final List<Post> posts;
}
