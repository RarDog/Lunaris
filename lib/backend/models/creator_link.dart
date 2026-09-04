import 'package:flutter/material.dart';

enum CreatorLinkType {
  youtube,
  twitter,
  instagram,
  tiktok,
  discord,
  pixiv,
  fanbox,
  patreon,
  fantia,
  boosty,
  twitch,
  telegram,
  gumroad,
  subscribestar,
  artstation,
  deviantart,
  linkhub,
  other,
}

class CreatorLink {
  const CreatorLink({
    required this.url,
    required this.type,
    required this.title,
    this.customLabel,
  });

  final String url;
  final CreatorLinkType type;
  final String title;
  final String? customLabel;

  String get serviceName {
    switch (type) {
      case CreatorLinkType.youtube:
        return 'YouTube';
      case CreatorLinkType.twitter:
        return 'X (Twitter)';
      case CreatorLinkType.instagram:
        return 'Instagram';
      case CreatorLinkType.tiktok:
        return 'TikTok';
      case CreatorLinkType.discord:
        return 'Discord';
      case CreatorLinkType.pixiv:
        return 'Pixiv';
      case CreatorLinkType.fanbox:
        return 'Fanbox';
      case CreatorLinkType.patreon:
        return 'Patreon';
      case CreatorLinkType.fantia:
        return 'Fantia';
      case CreatorLinkType.boosty:
        return 'Boosty';
      case CreatorLinkType.twitch:
        return 'Twitch';
      case CreatorLinkType.telegram:
        return 'Telegram';
      case CreatorLinkType.gumroad:
        return 'Gumroad';
      case CreatorLinkType.subscribestar:
        return 'SubscribeStar';
      case CreatorLinkType.artstation:
        return 'ArtStation';
      case CreatorLinkType.deviantart:
        return 'DeviantArt';
      case CreatorLinkType.linkhub:
        return 'Links Hub';
      case CreatorLinkType.other:
        return title.isNotEmpty ? title : 'Web Link';
    }
  }

  Color get brandColor {
    switch (type) {
      case CreatorLinkType.youtube:
        return const Color(0xFFFF0000); // YouTube Red
      case CreatorLinkType.twitter:
        return const Color(0xFF1D9BF0); // Twitter Blue
      case CreatorLinkType.instagram:
        return const Color(0xFFE1306C); // Instagram Gradient Magenta
      case CreatorLinkType.tiktok:
        return const Color(0xFF00F2FE); // TikTok Cyan
      case CreatorLinkType.discord:
        return const Color(0xFF5865F2); // Discord Blurple
      case CreatorLinkType.pixiv:
        return const Color(0xFF0096FA); // Pixiv Blue
      case CreatorLinkType.fanbox:
        return const Color(0xFFF1A12F); // Fanbox Orange
      case CreatorLinkType.patreon:
        return const Color(0xFFFF424D); // Patreon Coral
      case CreatorLinkType.fantia:
        return const Color(0xFFE0245E); // Fantia Pink
      case CreatorLinkType.boosty:
        return const Color(0xFFF15A24); // Boosty Orange
      case CreatorLinkType.twitch:
        return const Color(0xFF9146FF); // Twitch Purple
      case CreatorLinkType.telegram:
        return const Color(0xFF2AABEE); // Telegram Blue
      case CreatorLinkType.gumroad:
        return const Color(0xFFFF90E8); // Gumroad Pink
      case CreatorLinkType.subscribestar:
        return const Color(0xFF00ADB5); // SubscribeStar Teal
      case CreatorLinkType.artstation:
        return const Color(0xFF13AFF0); // ArtStation Blue
      case CreatorLinkType.deviantart:
        return const Color(0xFF05CC47); // DeviantArt Green
      case CreatorLinkType.linkhub:
        return const Color(0xFF43E660); // Linktree Green
      case CreatorLinkType.other:
        return const Color(0xFF5C6BC0); // Indigo
    }
  }

  IconData get iconData {
    switch (type) {
      case CreatorLinkType.youtube:
        return Icons.smart_display_rounded;
      case CreatorLinkType.twitter:
        return Icons.alternate_email_rounded;
      case CreatorLinkType.instagram:
        return Icons.camera_alt_rounded;
      case CreatorLinkType.tiktok:
        return Icons.music_note_rounded;
      case CreatorLinkType.discord:
        return Icons.forum_rounded;
      case CreatorLinkType.pixiv:
        return Icons.palette_rounded;
      case CreatorLinkType.fanbox:
        return Icons.favorite_rounded;
      case CreatorLinkType.patreon:
        return Icons.volunteer_activism_rounded;
      case CreatorLinkType.fantia:
        return Icons.stars_rounded;
      case CreatorLinkType.boosty:
        return Icons.rocket_launch_rounded;
      case CreatorLinkType.twitch:
        return Icons.live_tv_rounded;
      case CreatorLinkType.telegram:
        return Icons.send_rounded;
      case CreatorLinkType.gumroad:
        return Icons.shopping_bag_rounded;
      case CreatorLinkType.subscribestar:
        return Icons.star_rounded;
      case CreatorLinkType.artstation:
      case CreatorLinkType.deviantart:
        return Icons.brush_rounded;
      case CreatorLinkType.linkhub:
        return Icons.link_rounded;
      case CreatorLinkType.other:
        return Icons.language_rounded;
    }
  }

  static final _urlRegex = RegExp(
    r'''https?://[^\s<>"{}|\\^`\[\]]+''',
    caseSensitive: false,
  );

  static final _htmlLinkRegex = RegExp(
    r"""<a\s+[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>""",
    caseSensitive: false,
    dotAll: true,
  );

  static const _cloudDriveHosts = {
    'drive.google.com',
    'mega.nz',
    'mega.co.nz',
    'dropbox.com',
    'pixeldrain.com',
    'mediafire.com',
    'catbox.moe',
    'bunkr.',
    'gofile.io',
    'terabox.com',
    '1024tera.com',
    'dubox.com',
  };

  /// Extracts all social media, creator profiles and external web links from text.
  static List<CreatorLink> extractLinks(
    String? text, {
    bool excludeCloudDrives = true,
  }) {
    if (text == null || text.trim().isEmpty) return const [];
    final results = <CreatorLink>[];
    final seenUrls = <String>{};

    void processUrl(String rawUrl, {String? customTitle}) {
      var url = rawUrl.trim();
      while (url.isNotEmpty &&
          (url.endsWith(')') ||
              url.endsWith('.') ||
              url.endsWith(',') ||
              url.endsWith(';') ||
              url.endsWith('!') ||
              url.endsWith('?') ||
              url.endsWith(':') ||
              url.endsWith('>'))) {
        url = url.substring(0, url.length - 1);
      }
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
        return;
      }
      if (seenUrls.contains(url)) return;
      seenUrls.add(url);

      final host = uri.host.toLowerCase();
      if (excludeCloudDrives) {
        if (_cloudDriveHosts.any((ch) => host.contains(ch))) {
          return;
        }
      }

      final (type, defaultTitle) = _classifyHost(uri);
      results.add(CreatorLink(
        url: url,
        type: type,
        title: (customTitle != null && customTitle.isNotEmpty && customTitle != url)
            ? customTitle
            : defaultTitle,
      ));
    }

    // 1. Process HTML anchors
    if (text.contains('<a ')) {
      for (final match in _htmlLinkRegex.allMatches(text)) {
        final href = match.group(1);
        final rawTitle = match.group(2);
        final cleanTitle =
            rawTitle?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? '';
        if (href != null && href.isNotEmpty) {
          processUrl(href, customTitle: cleanTitle.isNotEmpty ? cleanTitle : null);
        }
      }
    }

    // 2. Process all plain URLs
    for (final match in _urlRegex.allMatches(text)) {
      final url = match.group(0);
      if (url != null) processUrl(url);
    }

    return results;
  }

  static (CreatorLinkType, String) _classifyHost(Uri uri) {
    final host = uri.host.toLowerCase();

    // YouTube
    if (host.contains('youtube.com') || host.contains('youtu.be')) {
      return (CreatorLinkType.youtube, 'YouTube');
    }
    // X / Twitter
    if (host.contains('twitter.com') || host.contains('x.com') || host == 't.co') {
      return (CreatorLinkType.twitter, 'X (Twitter)');
    }
    // Instagram
    if (host.contains('instagram.com') || host.contains('instagr.am')) {
      return (CreatorLinkType.instagram, 'Instagram');
    }
    // TikTok
    if (host.contains('tiktok.com')) {
      return (CreatorLinkType.tiktok, 'TikTok');
    }
    // Discord
    if (host.contains('discord.gg') || host.contains('discord.com')) {
      return (CreatorLinkType.discord, 'Discord');
    }
    // Pixiv
    if (host.contains('pixiv.net')) {
      return (CreatorLinkType.pixiv, 'Pixiv');
    }
    // Fanbox
    if (host.contains('fanbox.cc')) {
      return (CreatorLinkType.fanbox, 'Fanbox');
    }
    // Patreon
    if (host.contains('patreon.com')) {
      return (CreatorLinkType.patreon, 'Patreon');
    }
    // Fantia
    if (host.contains('fantia.jp')) {
      return (CreatorLinkType.fantia, 'Fantia');
    }
    // Boosty
    if (host.contains('boosty.to')) {
      return (CreatorLinkType.boosty, 'Boosty');
    }
    // Twitch
    if (host.contains('twitch.tv')) {
      return (CreatorLinkType.twitch, 'Twitch');
    }
    // Telegram
    if (host.contains('t.me') || host.contains('telegram.me')) {
      return (CreatorLinkType.telegram, 'Telegram');
    }
    // Gumroad
    if (host.contains('gumroad.com')) {
      return (CreatorLinkType.gumroad, 'Gumroad');
    }
    // SubscribeStar
    if (host.contains('subscribestar.adult') || host.contains('subscribestar.com')) {
      return (CreatorLinkType.subscribestar, 'SubscribeStar');
    }
    // ArtStation
    if (host.contains('artstation.com')) {
      return (CreatorLinkType.artstation, 'ArtStation');
    }
    // DeviantArt
    if (host.contains('deviantart.com')) {
      return (CreatorLinkType.deviantart, 'DeviantArt');
    }
    // Link hubs
    if (host.contains('linktr.ee') || host.contains('carrd.co') || host.contains('lit.link')) {
      return (CreatorLinkType.linkhub, 'Links Hub');
    }

    // Default clean host name
    var cleanHost = host.replaceFirst(RegExp(r'^www\.'), '');
    if (cleanHost.length > 25) {
      cleanHost = cleanHost.substring(0, 25);
    }
    return (CreatorLinkType.other, cleanHost.isNotEmpty ? cleanHost : 'Web Link');
  }
}
