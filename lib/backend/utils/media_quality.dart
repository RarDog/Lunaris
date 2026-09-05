import '../models/post.dart';

enum MediaQualityMode {
  auto,
  dataSaver,
  highQuality;

  static MediaQualityMode fromName(String value) {
    return MediaQualityMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => MediaQualityMode.auto,
    );
  }

  String get label {
    return switch (this) {
      MediaQualityMode.auto => 'Auto',
      MediaQualityMode.dataSaver => 'Data saver',
      MediaQualityMode.highQuality => 'High quality',
    };
  }
}

class MediaUrlSelector {
  const MediaUrlSelector._();

  static List<String> feed(
    Post post, {
    MediaQualityMode mode = MediaQualityMode.auto,
    bool mobile = false,
  }) {
    return switch (mode) {
      MediaQualityMode.dataSaver => _compact([post.previewUrl, post.sampleUrl]),
      MediaQualityMode.highQuality =>
        _compact([post.sampleUrl, post.previewUrl]),
      MediaQualityMode.auto => mobile
          ? _compact([post.previewUrl, post.sampleUrl])
          : _compact([post.sampleUrl, post.previewUrl]),
    };
  }

  static List<String> preview(Post post) {
    return _compact([post.sampleUrl, post.previewUrl, post.fileUrl]);
  }

  static List<String> details(
    Post post, {
    MediaQualityMode mode = MediaQualityMode.auto,
  }) {
    if (_isVideo(post)) {
      return _compact([post.fileUrl, post.sampleUrl, post.previewUrl]);
    }
    if (_isGif(post)) {
      return switch (mode) {
        MediaQualityMode.dataSaver =>
          _compact([post.sampleUrl, post.previewUrl, post.fileUrl]),
        _ => _compact([post.fileUrl, post.sampleUrl, post.previewUrl]),
      };
    }
    return switch (mode) {
      MediaQualityMode.dataSaver =>
        _compact([post.sampleUrl, post.previewUrl, post.fileUrl]),
      MediaQualityMode.highQuality =>
        _compact([post.fileUrl, post.sampleUrl, post.previewUrl]),
      MediaQualityMode.auto =>
        _compact([post.sampleUrl, post.fileUrl, post.previewUrl]),
    };
  }

  static String? download(Post post) {
    return _compact([post.fileUrl, post.sampleUrl, post.previewUrl])
        .firstOrNull;
  }

  static List<String> video(Post post) {
    return _compact([
      post.fileUrl,
      if (_looksLikeVideoUrl(post.sampleUrl)) post.sampleUrl,
      if (_looksLikeVideoUrl(post.previewUrl)) post.previewUrl,
    ]);
  }

  static List<String> audio(Post post) {
    return _compact([
      post.fileUrl,
      if (_looksLikeAudioUrl(post.sampleUrl)) post.sampleUrl,
      if (_looksLikeAudioUrl(post.previewUrl)) post.previewUrl,
    ]);
  }

  static bool isVideo(Post post) => _isVideo(post);
  static bool isAudio(Post post) => _isAudio(post);
  static bool isGif(Post post) => _isGif(post);

  static List<String> _compact(Iterable<String> urls) {
    final seen = <String>{};
    return urls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty && seen.add(url))
        .toList(growable: false);
  }

  static const _videoExtensions = {
    '.mp4',
    '.webm',
    '.mov',
    '.mkv',
    '.avi',
    '.flv',
    '.wmv',
    '.m4v',
    '.ts',
  };

  static const _audioExtensions = {
    '.mp3',
    '.m4a',
    '.wav',
    '.ogg',
    '.flac',
    '.aac',
    '.opus',
    '.wma',
  };

  static String _extractExtension(String url) {
    if (url.isEmpty) return '';
    try {
      final uri = Uri.parse(url);
      final filenameParam =
          uri.queryParameters['f'] ?? uri.queryParameters['filename'];
      if (filenameParam != null && filenameParam.isNotEmpty) {
        final cleanParam = filenameParam.split('?').first.split('#').first;
        final dot = cleanParam.lastIndexOf('.');
        if (dot != -1 && dot < cleanParam.length - 1) {
          final ext = cleanParam.substring(dot).toLowerCase();
          if (ext.length <= 6) return ext;
        }
      }
      final path = uri.path;
      final dot = path.lastIndexOf('.');
      if (dot != -1 && dot < path.length - 1) {
        final ext = path.substring(dot).toLowerCase();
        if (ext.length <= 6) return ext;
      }
    } catch (_) {
      // Uri parsing failed, fallback below
    }

    final clean = url.split('?').first.split('#').first;
    final dot = clean.lastIndexOf('.');
    if (dot != -1 && dot < clean.length - 1) {
      final ext = clean.substring(dot).toLowerCase();
      if (ext.length <= 6) return ext;
    }
    return '';
  }

  static bool _isAudio(Post post) {
    final type = post.fileType.toLowerCase().trim();
    if (type == 'audio') return true;
    if (type == 'video' || type == 'photo' || type == 'archive' || type == 'gif') {
      return false;
    }

    final fileExt = _extractExtension(post.fileUrl);
    if (_audioExtensions.contains(fileExt)) return true;
    if (_videoExtensions.contains(fileExt)) return false;

    final sampleExt = _extractExtension(post.sampleUrl);
    if (_audioExtensions.contains(sampleExt)) return true;
    if (_videoExtensions.contains(sampleExt)) return false;

    return false;
  }

  static bool _isVideo(Post post) {
    final type = post.fileType.toLowerCase().trim();
    if (type == 'video') return true;
    if (type == 'audio' || type == 'photo' || type == 'archive' || type == 'gif') {
      return false;
    }

    final fileExt = _extractExtension(post.fileUrl);
    if (_videoExtensions.contains(fileExt)) return true;
    if (_audioExtensions.contains(fileExt)) return false;

    final sampleExt = _extractExtension(post.sampleUrl);
    if (_videoExtensions.contains(sampleExt)) return true;
    if (_audioExtensions.contains(sampleExt)) return false;

    return false;
  }

  static bool _isGif(Post post) {
    final type = post.fileType.toLowerCase().trim();
    if (type == 'gif') return true;
    final fileExt = _extractExtension(post.fileUrl);
    if (fileExt == '.gif') return true;
    final sampleExt = _extractExtension(post.sampleUrl);
    return sampleExt == '.gif';
  }

  static bool _looksLikeVideoUrl(String url) {
    final ext = _extractExtension(url);
    return _videoExtensions.contains(ext);
  }

  static bool _looksLikeAudioUrl(String url) {
    final ext = _extractExtension(url);
    return _audioExtensions.contains(ext);
  }
}

