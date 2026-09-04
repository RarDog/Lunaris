import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/models/cloud_media_link.dart';
import 'package:gel_rule_app/backend/services/cloud_link_extractor.dart';

void main() {
  group('CloudLinkExtractor tests', () {
    test('extracts and parses Google Drive links with direct stream URLs', () {
      const html = '''
        <p>New animation release!</p>
        <p>Download here: <a href="https://drive.google.com/file/d/1AbC-DeFgHiJkLmNoPqRsTuVwXyZ123/view?usp=sharing">Google Drive 4K</a></p>
        <p>Or browse the full folder: https://drive.google.com/drive/folders/9ZyX-WvUtSrQpOnMlKjIhGfEdCbA456</p>
      ''';

      final links = CloudLinkExtractor.extractLinks(content: html);
      expect(links.length, 2);

      final fileLink = links.firstWhere((l) => l.service == CloudServiceType.googleDrive && !l.isFolder);
      expect(fileLink.title, 'Google Drive 4K');
      expect(fileLink.isStreamable, isTrue);
      expect(fileLink.directStreamUrl, 'https://drive.google.com/uc?export=download&id=1AbC-DeFgHiJkLmNoPqRsTuVwXyZ123');

      final folderLink = links.firstWhere((l) => l.service == CloudServiceType.googleDrive && l.isFolder);
      expect(folderLink.isFolder, isTrue);
      expect(folderLink.isStreamable, isFalse);
    });

    test('extracts MEGA links and detects folders', () {
      const content = '''
        Archive mirrors:
        Mega file: https://mega.nz/file/xyz123#abcdefg
        Mega folder: https://mega.nz/folder/abc456#1234567
      ''';

      final links = CloudLinkExtractor.extractLinks(content: content);
      expect(links.length, 2);

      final fileLink = links.firstWhere((l) => !l.isFolder);
      expect(fileLink.service, CloudServiceType.mega);
      expect(fileLink.serviceName, 'MEGA');
      expect(fileLink.isFolder, isFalse);

      final folderLink = links.firstWhere((l) => l.isFolder);
      expect(folderLink.service, CloudServiceType.mega);
      expect(folderLink.isFolder, isTrue);
    });

    test('transforms Dropbox links into direct stream URLs with ?raw=1', () {
      const content = 'https://www.dropbox.com/s/sample123/video.mp4?dl=0';
      final links = CloudLinkExtractor.extractLinks(content: content);
      expect(links.length, 1);
      final link = links.first;
      expect(link.service, CloudServiceType.dropbox);
      expect(link.isStreamable, isTrue);
      expect(link.directStreamUrl, 'https://www.dropbox.com/s/sample123/video.mp4?raw=1');
    });

    test('extracts Pixeldrain file IDs and generates API endpoints', () {
      const content = 'Pixeldrain mirror: https://pixeldrain.com/u/abc123xy';
      final links = CloudLinkExtractor.extractLinks(content: content);
      expect(links.length, 1);
      final link = links.first;
      expect(link.service, CloudServiceType.pixeldrain);
      expect(link.isStreamable, isTrue);
      expect(link.directStreamUrl, 'https://pixeldrain.com/api/file/abc123xy');
    });

    test('extracts archive passwords from content', () {
      expect(
        CloudLinkExtractor.extractPassword('Here is the zip! Password: SuperSecret123'),
        'SuperSecret123',
      );
      expect(
        CloudLinkExtractor.extractPassword('Pass = pass_word_2026!'),
        'pass_word_2026!',
      );
      expect(
        CloudLinkExtractor.extractPassword('Пароль: mypass777'),
        'mypass777',
      );
    });

    test('cleans HTML commentary correctly', () {
      const html = '<p>Hello world!<br/>Check out the new video.</p><p>&amp; enjoy!</p>';
      final clean = CloudLinkExtractor.cleanCommentary(html);
      expect(clean, 'Hello world!\nCheck out the new video.\n\n& enjoy!');
    });

    test('encodes and decodes CloudMediaLink to and from JSON', () {
      const link = CloudMediaLink(
        url: 'https://mega.nz/file/123#abc',
        service: CloudServiceType.mega,
        title: 'Full 4K Video',
        isFolder: false,
        isStreamable: false,
        detectedPassword: 'pass',
      );

      final encoded = link.encode();
      final decoded = CloudMediaLink.tryDecode(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.url, link.url);
      expect(decoded.service, CloudServiceType.mega);
      expect(decoded.title, 'Full 4K Video');
      expect(decoded.detectedPassword, 'pass');
    });
  });
}
