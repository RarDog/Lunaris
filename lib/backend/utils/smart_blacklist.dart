import '../models/post.dart';

class SmartBlacklistMatcher {
  const SmartBlacklistMatcher._();

  static bool matches(Post post, String rule) {
    final tokens = rule
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
    if (tokens.isEmpty) return false;
    return tokens.every((token) => _matchesToken(post, token));
  }

  static bool _matchesToken(Post post, String token) {
    final parts = token.split(':');
    if (parts.length >= 2) {
      final key = parts.first;
      final value = parts.sublist(1).join(':');
      return switch (key) {
        'provider' => post.providerId.toLowerCase() == value,
        'rating' => post.rating.toLowerCase() == value ||
            post.rating.toLowerCase().startsWith(value),
        'type' || 'filetype' => post.fileType.toLowerCase().contains(value),
        'score' => _scoreMatches(post.score, value),
        'artist' ||
        'character' ||
        'copyright' ||
        'meta' ||
        'general' =>
          _groupContains(post, key, value),
        _ => _allTags(post).contains(token),
      };
    }
    return _allTags(post).contains(token);
  }

  static bool _scoreMatches(int score, String value) {
    if (value.startsWith('>=')) {
      return score >= (int.tryParse(value.substring(2)) ?? score + 1);
    }
    if (value.startsWith('<=')) {
      return score <= (int.tryParse(value.substring(2)) ?? score - 1);
    }
    if (value.startsWith('>')) {
      return score > (int.tryParse(value.substring(1)) ?? score);
    }
    if (value.startsWith('<')) {
      return score < (int.tryParse(value.substring(1)) ?? score);
    }
    return score == int.tryParse(value);
  }

  static bool _groupContains(Post post, String group, String tag) {
    return (post.tagGroups[group] ?? const [])
        .map((value) => value.toLowerCase())
        .contains(tag);
  }

  static Set<String> _allTags(Post post) {
    return {
      ...post.tags,
      for (final group in post.tagGroups.values) ...group,
    }.map((tag) => tag.toLowerCase()).toSet();
  }
}

List<String> similarTagsFor(Post post) {
  final priority = [
    ...post.tagGroups['artist'] ?? const <String>[],
    ...post.tagGroups['character'] ?? const <String>[],
    ...post.tagGroups['copyright'] ?? const <String>[],
  ].where((tag) => tag.trim().isNotEmpty).toSet().take(5).toList();
  if (priority.isNotEmpty) return priority;
  return post.tags.where((tag) => tag.trim().isNotEmpty).take(5).toList();
}
