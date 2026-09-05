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

  static bool _isAudio(Post post) {
    final value = '${post.fileType} ${post.fileUrl}'.toLowerCase();
    return value.contains('audio') ||
        value.contains('.mp3') ||
        value.contains('.m4a') ||
        value.contains('.wav') ||
        value.contains('.ogg') ||
        value.contains('.flac') ||
        value.contains('.aac') ||
        value.contains('.opus') ||
        value.contains('.wma');
  }

  static bool _isVideo(Post post) {
    if (_isAudio(post)) return false;
    final value = '${post.fileType} ${post.fileUrl}'.toLowerCase();
    return value.contains('video') ||
        value.contains('.webm') ||
        value.contains('.mp4') ||
        value.contains('.mov') ||
        value.contains('.mkv') ||
        value.contains('.avi') ||
        value.contains('.flv') ||
        value.contains('.wmv') ||
        value.contains('.m4v') ||
        value.contains('.ts');
  }

  static bool _isGif(Post post) {
    final value = '${post.fileType} ${post.fileUrl}'.toLowerCase();
    return value.contains('gif') || value.contains('.gif');
  }

  static bool _looksLikeVideoUrl(String url) {
    final value = url.toLowerCase();
    return value.contains('.webm') ||
        value.contains('.mp4') ||
        value.contains('.mov') ||
        value.contains('.mkv') ||
        value.contains('.avi') ||
        value.contains('.flv') ||
        value.contains('.wmv') ||
        value.contains('.m4v') ||
        value.contains('.ts');
  }

  static bool _looksLikeAudioUrl(String url) {
    final value = url.toLowerCase();
    return value.contains('.mp3') ||
        value.contains('.m4a') ||
        value.contains('.wav') ||
        value.contains('.ogg') ||
        value.contains('.flac') ||
        value.contains('.aac') ||
        value.contains('.opus') ||
        value.contains('.wma');
  }
}
