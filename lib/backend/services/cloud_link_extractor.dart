import '../models/cloud_media_link.dart';

class CloudLinkExtractor {
  static final _urlRegex = RegExp(
    r'''https?://[^\s<>"{}|\\^`\[\]]+''',
    caseSensitive: false,
  );

  static final _htmlLinkRegex = RegExp(
    r"""<a\s+[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>""",
    caseSensitive: false,
    dotAll: true,
  );

  static final _passwordRegex = RegExp(
    r'(?:pass(?:word)?|pw|пароль|пас)(?:[\s:=_-]+)([^\s,;<>"\n\r]{2,50})',
    caseSensitive: false,
  );

  /// Extracts any archive password mentioned in the raw text/HTML.
  static String? extractPassword(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final match = _passwordRegex.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      final pass = match.group(1)?.trim();
      if (pass != null &&
          pass.isNotEmpty &&
          !pass.startsWith('http') &&
          pass.toLowerCase() != 'none') {
        return pass;
      }
    }
    return null;
  }

  /// Extracts all cloud media and video mirror links from text, HTML, and embeds.
  static List<CloudMediaLink> extractLinks({
    String? content,
    String? source,
    Map<String, dynamic>? embed,
  }) {
    final results = <CloudMediaLink>[];
    final seenUrls = <String>{};
    final detectedPass = extractPassword(content);

    void addLink(String rawUrl, {String? customTitle}) {
      final cleanUrl = _cleanUrl(rawUrl);
      if (cleanUrl == null || seenUrls.contains(cleanUrl)) return;
      seenUrls.add(cleanUrl);

      final link = _classifyLink(cleanUrl, customTitle: customTitle, password: detectedPass);
      if (link != null) {
        results.add(link);
      }
    }

    // 1. Process HTML anchors first to preserve anchor text / custom title
    if (content != null && content.contains('<a ')) {
      for (final match in _htmlLinkRegex.allMatches(content)) {
        final href = match.group(1);
        final rawTitle = match.group(2);
        final cleanTitle = _stripHtml(rawTitle);
        if (href != null && href.isNotEmpty) {
          addLink(href, customTitle: cleanTitle.isNotEmpty ? cleanTitle : null);
        }
      }
    }

    // 2. Process all URLs in content text
    if (content != null) {
      for (final match in _urlRegex.allMatches(content)) {
        final url = match.group(0);
        if (url != null) addLink(url);
      }
    }

    // 3. Process source
    if (source != null && source.trim().isNotEmpty) {
      for (final match in _urlRegex.allMatches(source)) {
        final url = match.group(0);
        if (url != null) addLink(url);
      }
    }

    // 4. Process embed map
    if (embed != null) {
      final embedUrl = embed['url']?.toString();
      if (embedUrl != null && embedUrl.isNotEmpty) {
        final title = embed['title']?.toString();
        addLink(embedUrl, customTitle: title);
      }
    }

    return results;
  }

  static String? _cleanUrl(String raw) {
    var url = raw.trim();
    // Trim trailing punctuation like ), ., ,, ;, etc.
    while (url.isNotEmpty && (url.endsWith(')') || url.endsWith('.') || url.endsWith(',') || url.endsWith(';') || url.endsWith('>'))) {
      url = url.substring(0, url.length - 1);
    }
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme || (!parsed.scheme.startsWith('http'))) {
      return null;
    }
    return url;
  }

  static String _stripHtml(String? html) {
    if (html == null) return '';
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  static CloudMediaLink? _classifyLink(
    String url, {
    String? customTitle,
    String? password,
  }) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();

    // Google Drive
    if (host.contains('drive.google.com')) {
      final isFolder = path.contains('/folders/') || uri.queryParameters.containsKey('folder');
      String? directStreamUrl;
      final fileIdMatch = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(uri.path);
      final idParam = fileIdMatch?.group(1) ?? uri.queryParameters['id'];
      if (idParam != null && !isFolder) {
        directStreamUrl = 'https://drive.google.com/uc?export=download&id=$idParam';
      }
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.googleDrive,
        title: customTitle ?? (isFolder ? 'Google Drive Folder' : 'Google Drive File'),
        directStreamUrl: directStreamUrl,
        isFolder: isFolder,
        isStreamable: directStreamUrl != null,
        detectedPassword: password,
      );
    }

    // MEGA
    if (host.contains('mega.nz') || host.contains('mega.co.nz')) {
      final isFolder = url.contains('/folder/') || url.contains('/#F!') || url.contains('#F!');
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.mega,
        title: customTitle ?? (isFolder ? 'MEGA Cloud Folder' : 'MEGA Video / Archive'),
        directStreamUrl: null, // End-to-end encrypted; launches in MEGA app/browser
        isFolder: isFolder,
        isStreamable: false,
        detectedPassword: password,
      );
    }

    // Dropbox
    if (host.contains('dropbox.com')) {
      final isFolder = path.contains('/sh/') || path.contains('/folder');
      var direct = url;
      if (direct.contains('?dl=0')) {
        direct = direct.replaceAll('?dl=0', '?raw=1');
      } else if (!direct.contains('?raw=1') && !isFolder) {
        direct = direct.contains('?') ? '$direct&raw=1' : '$direct?raw=1';
      }
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.dropbox,
        title: customTitle ?? (isFolder ? 'Dropbox Folder' : 'Dropbox Media'),
        directStreamUrl: isFolder ? null : direct,
        isFolder: isFolder,
        isStreamable: !isFolder,
        detectedPassword: password,
      );
    }

    // Pixeldrain
    if (host.contains('pixeldrain.com')) {
      final fileMatch = RegExp(r'/u/([a-zA-Z0-9_-]+)').firstMatch(uri.path);
      final isList = path.contains('/l/');
      final fileId = fileMatch?.group(1);
      final direct = fileId != null ? 'https://pixeldrain.com/api/file/$fileId' : null;
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.pixeldrain,
        title: customTitle ?? (isList ? 'Pixeldrain Gallery/List' : 'Pixeldrain Video'),
        directStreamUrl: direct,
        isFolder: isList,
        isStreamable: direct != null,
        detectedPassword: password,
      );
    }

    // Catbox / Litterbox
    if (host.contains('catbox.moe')) {
      final isVideo = path.endsWith('.mp4') || path.endsWith('.webm') || path.endsWith('.mov') || path.endsWith('.m4v');
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.catbox,
        title: customTitle ?? 'Catbox Upload',
        directStreamUrl: url,
        isFolder: false,
        isStreamable: isVideo,
        detectedPassword: password,
      );
    }

    // MediaFire
    if (host.contains('mediafire.com')) {
      final isFolder = path.contains('/folder/') || path.contains('/?');
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.mediafire,
        title: customTitle ?? (isFolder ? 'MediaFire Folder' : 'MediaFire Download'),
        directStreamUrl: null,
        isFolder: isFolder,
        isStreamable: false,
        detectedPassword: password,
      );
    }

    // Bunkr
    if (host.contains('bunkr.')) {
      final isAlbum = path.contains('/a/') || path.contains('/v/');
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.bunkr,
        title: customTitle ?? (isAlbum ? 'Bunkr Album' : 'Bunkr Media'),
        directStreamUrl: null,
        isFolder: isAlbum,
        isStreamable: false,
        detectedPassword: password,
      );
    }

    // GoFile
    if (host.contains('gofile.io')) {
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.gofile,
        title: customTitle ?? 'GoFile Folder / Archive',
        directStreamUrl: null,
        isFolder: true,
        isStreamable: false,
        detectedPassword: password,
      );
    }

    // TeraBox
    if (host.contains('terabox') || host.contains('1024tera') || host.contains('dubox')) {
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.terabox,
        title: customTitle ?? 'TeraBox Cloud Share',
        directStreamUrl: null,
        isFolder: true,
        isStreamable: false,
        detectedPassword: password,
      );
    }

    // Direct Video Link (MP4, WEBM, MKV, MOV)
    if (path.endsWith('.mp4') || path.endsWith('.webm') || path.endsWith('.mov') || path.endsWith('.m4v') || path.endsWith('.mkv')) {
      final filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'Video Stream';
      return CloudMediaLink(
        url: url,
        service: CloudServiceType.genericVideo,
        title: customTitle ?? filename,
        directStreamUrl: url,
        isFolder: false,
        isStreamable: true,
        detectedPassword: password,
      );
    }

    // Ignore known booru and search engine domains
    if (host.contains('kemono') ||
        host.contains('coomer') ||
        host.contains('danbooru') ||
        host.contains('gelbooru') ||
        host.contains('google.com') && !host.contains('drive') ||
        host.contains('twitter.com') ||
        host.contains('x.com') ||
        host.contains('patreon.com') ||
        host.contains('fanbox.cc') ||
        host.contains('pixiv.net')) {
      return null;
    }

    return null;
  }

  /// Extracts clean text (stripping HTML tags) suitable for author commentary display.
  static String cleanCommentary(String? rawHtml) {
    if (rawHtml == null || rawHtml.trim().isEmpty) return '';
    var text = rawHtml
        .replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<\/p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return text.trim();
  }
}
