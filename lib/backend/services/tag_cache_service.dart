import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/tag_suggestion.dart';

class TagCacheService {
  TagCacheService({String? customPath}) : _customPath = customPath;

  final String? _customPath;
  final Map<String, TagSuggestion> _tags = {};
  bool _isInitialized = false;
  Timer? _saveDebounce;
  String? _resolvedPath;

  bool get isInitialized => _isInitialized;
  int get tagCount => _tags.length;

  Future<String> _getCacheFilePath() async {
    if (_resolvedPath != null) return _resolvedPath!;
    if (_customPath != null) {
      _resolvedPath = _customPath;
      return _resolvedPath!;
    }
    final dir = await getApplicationDocumentsDirectory();
    _resolvedPath = '${dir.path}/lunaris_tag_cache.json';
    return _resolvedPath!;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final path = await _getCacheFilePath();
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            for (final item in decoded) {
              if (item is Map) {
                final suggestion = TagSuggestion.fromJson(
                  Map<String, dynamic>.from(item),
                );
                final key = suggestion.name.trim().toLowerCase();
                if (key.isNotEmpty) {
                  _tags[key] = suggestion;
                }
              }
            }
          }
        }
      }
    } catch (_) {
      // Non-critical: corrupted cache file can be rebuilt seamlessly
    } finally {
      _isInitialized = true;
    }
  }

  /// Finds suggestions locally in memory (0 ms response).
  List<TagSuggestion> findLocal(
    String prefix, {
    int limit = 16,
    Iterable<String>? priorityTags,
  }) {
    final cleanPrefix = prefix
        .replaceAll(RegExp(r'^[\(\)]+|[\(\)]+$'), '')
        .trim()
        .toLowerCase();
    if (cleanPrefix.isEmpty) return const [];

    final prioritySet = priorityTags
            ?.map((t) => t.trim().toLowerCase())
            .where((t) => t.isNotEmpty)
            .toSet() ??
        const <String>{};

    final matches = <TagSuggestion>[];
    final seen = <String>{};

    // First check priority tags (e.g. from recent search history)
    for (final tag in prioritySet) {
      if (tag.startsWith(cleanPrefix) && !seen.contains(tag)) {
        seen.add(tag);
        final existing = _tags[tag];
        matches.add(
          existing ??
              TagSuggestion(
                name: tag,
                category: TagCategory.general,
                postCount: 0,
                providerId: 'history',
              ),
        );
      }
    }

    // Then check all cached tags
    for (final entry in _tags.entries) {
      if (seen.contains(entry.key)) continue;
      if (entry.key.startsWith(cleanPrefix)) {
        seen.add(entry.key);
        matches.add(entry.value);
      }
    }

    matches.sort((a, b) {
      final aKey = a.name.toLowerCase();
      final bKey = b.name.toLowerCase();
      final aExact = aKey == cleanPrefix;
      final bExact = bKey == cleanPrefix;
      if (aExact != bExact) return aExact ? -1 : 1;

      final aPriority = prioritySet.contains(aKey);
      final bPriority = prioritySet.contains(bKey);
      if (aPriority != bPriority) return aPriority ? -1 : 1;

      final countCmp = b.postCount.compareTo(a.postCount);
      if (countCmp != 0) return countCmp;

      return aKey.compareTo(bKey);
    });

    return matches.take(limit.clamp(1, 50)).toList(growable: false);
  }

  /// Caches newly discovered suggestions and debounces saving to disk.
  Future<void> cacheTags(
    Iterable<TagSuggestion> suggestions, {
    int maxLimit = 5000,
  }) async {
    if (!_isInitialized) await init();
    var changed = false;

    for (final item in suggestions) {
      final key = item.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      final existing = _tags[key];
      if (existing == null || item.postCount > existing.postCount) {
        _tags[key] = item;
        changed = true;
      }
    }

    if (!changed) return;

    // Prune least popular tags if exceeding max limit
    if (_tags.length > maxLimit) {
      final sorted = _tags.values.toList()
        ..sort((a, b) => b.postCount.compareTo(a.postCount));
      _tags.clear();
      for (final item in sorted.take(maxLimit)) {
        _tags[item.name.toLowerCase()] = item;
      }
    }

    _scheduleSave();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 1200), () {
      flush();
    });
  }

  Future<void> flush() async {
    _saveDebounce?.cancel();
    try {
      final path = await _getCacheFilePath();
      final file = File(path);
      final list = _tags.values.map((t) => t.toJson()).toList(growable: false);
      final jsonString = jsonEncode(list);
      await file.writeAsString(jsonString, flush: true);
    } catch (_) {
      // Silent error on persistence failure
    }
  }

  Future<int> getFileSizeBytes() async {
    try {
      final path = await _getCacheFilePath();
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (_) {}
    return 0;
  }

  Future<void> clear() async {
    _saveDebounce?.cancel();
    _tags.clear();
    try {
      final path = await _getCacheFilePath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
