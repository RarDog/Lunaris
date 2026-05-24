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

  Future<Result<List<ContentProviderConfig>>> loadConfigs({
    bool enabledOnly = true,
  }) async {
    await _repository.ensureSeedProviders();
    return _repository.getProviders(enabledOnly: enabledOnly);
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

  Future<Result<void>> enableProvider(String id, bool enabled) async {
    final result = await _repository.getProvider(id);
    return result.fold(
      onSuccess: (config) {
        if (config == null) {
          return const Error<void>(
            Failure(code: 'not_found', message: 'Provider not found'),
          );
        }
        return _repository.saveProvider(
          config.copyWith(enabled: enabled, updatedAt: DateTime.now()),
        );
      },
      onError: Error<void>.new,
    );
  }

  Future<Result<void>> addCustomProvider(ContentProviderConfig config) {
    return _repository.saveProvider(config.copyWith(updatedAt: DateTime.now()));
  }

  Future<Result<void>> deleteProvider(String id) =>
      _repository.deleteProvider(id);

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

  Future<Result<List<Post>>> searchAcrossProviders({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
    String? providerId,
    TopPeriodFilter topPeriod = TopPeriodFilter.none,
  }) async {
    final providersResult = await activeProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    var providers = (providersResult as Success<List<ContentProvider>>).data;
    if (providerId != null) {
      providers =
          providers.where((provider) => provider.id == providerId).toList();
    }

    final seen = <String>{};
    final providerResults = <List<Post>>[];
    for (final provider in providers) {
      try {
        final providerPosts = await provider.searchPosts(
          tags: tags,
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
      }
    }
    final posts = providerId == null
        ? _interleaveProviderResults(providerResults, seen)
        : _flattenProviderResults(providerResults, seen);
    return Success(posts);
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
    var index = 0;
    while (true) {
      var added = false;
      for (final providerPosts in results) {
        if (index >= providerPosts.length) continue;
        final post = providerPosts[index];
        if (seen.add(post.cacheKey)) {
          posts.add(post);
          added = true;
        }
      }
      if (!added && results.every((items) => index >= items.length)) break;
      index++;
    }
    return posts;
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

  Future<Result<List<TagSuggestion>>> suggestTags(
    String query, {
    int limit = 20,
  }) async {
    final providersResult = await activeProviders();
    if (providersResult is Error<List<ContentProvider>>) {
      return Error(providersResult.failure);
    }
    final providers = (providersResult as Success<List<ContentProvider>>)
        .data
        .whereType<TagSuggestionProvider>()
        .toList();
    final suggestions = <String, TagSuggestion>{};
    for (final provider in providers) {
      try {
        final items = await provider.suggestTags(query, limit: limit);
        for (final item in items) {
          suggestions.putIfAbsent(
              '${item.providerId}:${item.name}', () => item);
        }
      } catch (_) {
        // Suggestions are non-critical; a failed provider should not affect UI.
      }
      if (suggestions.length >= limit) break;
    }
    final values = suggestions.values.toList()
      ..sort((a, b) => b.postCount.compareTo(a.postCount));
    return Success(values.take(limit).toList());
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
}
