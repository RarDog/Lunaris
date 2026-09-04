import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/creator_link.dart';

void main() {
  group('CreatorLink extractor and classification tests', () {
    test('extracts and classifies social and creator links accurately', () {
      const text = '''
Check out my latest speedpaint on YouTube: https://youtu.be/dQw4w9WgXcQ
Also follow my X account https://x.com/artist_handle and Instagram: https://instagram.com/p/C1234567/!
Support me on Patreon: https://www.patreon.com/my_art or Fanbox: https://artist.fanbox.cc
Join my Discord: https://discord.gg/invitelink
Other links: https://carrd.co/myportfolio and https://example.com/blog.
Cloud links like https://drive.google.com/file/d/123/view and https://mega.nz/file/abc should be excluded by default.
''';

      final links = CreatorLink.extractLinks(text);

      expect(links.length, 8);

      final yt = links.firstWhere((l) => l.type == CreatorLinkType.youtube);
      expect(yt.serviceName, 'YouTube');
      expect(yt.url, 'https://youtu.be/dQw4w9WgXcQ');

      final twitter = links.firstWhere((l) => l.type == CreatorLinkType.twitter);
      expect(twitter.serviceName, 'X (Twitter)');
      expect(twitter.url, 'https://x.com/artist_handle');

      final insta = links.firstWhere((l) => l.type == CreatorLinkType.instagram);
      expect(insta.serviceName, 'Instagram');
      expect(insta.url, 'https://instagram.com/p/C1234567/');

      final patreon = links.firstWhere((l) => l.type == CreatorLinkType.patreon);
      expect(patreon.serviceName, 'Patreon');

      final fanbox = links.firstWhere((l) => l.type == CreatorLinkType.fanbox);
      expect(fanbox.serviceName, 'Fanbox');

      final discord = links.firstWhere((l) => l.type == CreatorLinkType.discord);
      expect(discord.serviceName, 'Discord');

      final hub = links.firstWhere((l) => l.type == CreatorLinkType.linkhub);
      expect(hub.serviceName, 'Links Hub');

      final web = links.firstWhere((l) => l.type == CreatorLinkType.other);
      expect(web.url, 'https://example.com/blog');

      // Verify cloud storage was excluded
      expect(links.any((l) => l.url.contains('drive.google.com')), isFalse);
      expect(links.any((l) => l.url.contains('mega.nz')), isFalse);
    });

    test('handles HTML anchor links with custom titles', () {
      const html = '''
<p>Visit my <a href="https://twitter.com/draws">Twitter Profile</a> and watch on <a href="https://www.youtube.com/channel/123">YouTube Stream</a>!</p>
''';

      final links = CreatorLink.extractLinks(html);
      expect(links.length, 2);

      final tw = links.firstWhere((l) => l.type == CreatorLinkType.twitter);
      expect(tw.title, 'Twitter Profile');

      final yt = links.firstWhere((l) => l.type == CreatorLinkType.youtube);
      expect(yt.title, 'YouTube Stream');
    });
  });
}
