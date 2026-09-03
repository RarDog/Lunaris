import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/post.dart';
import '../utils/media_quality.dart';

class DownloadService {
  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  static const _channel = MethodChannel('rulegel/downloads');

  final Dio _dio;

  String resolveSubDir(Post post, String template) {
    if (template.isEmpty) return '';
    String artist = 'Unknown';
    final artistGroup =
        post.tagGroups['artist'] ?? post.tagGroups['creator'];
    if (artistGroup != null && artistGroup.isNotEmpty) {
      artist = artistGroup.first;
    } else {
      for (final tag in post.tags) {
        final lower = tag.toLowerCase();
        if (lower.startsWith('artist:') || lower.startsWith('creator:')) {
          final parts = tag.split(':');
          if (parts.length > 1 && parts[1].isNotEmpty) {
            artist = parts.sublist(1).join(':');
            break;
          }
        }
      }
    }
    artist = artist.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    var cleanTemplate = template.trim();
    if (cleanTemplate.toLowerCase().endsWith('/{id}')) {
      cleanTemplate =
          cleanTemplate.substring(0, cleanTemplate.length - 5).trim();
    }

    final resolved = cleanTemplate
        .replaceAll(
            '{Artist}', artist)
        .replaceAll(
            '{Provider}', post.providerName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'))
        .replaceAll(
            '{Service}', post.providerId.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'))
        .replaceAll(
            '{Rating}', post.rating.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'))
        .replaceAll(
            '{ID}', post.id.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'))
        .replaceAll('{Date}', dateStr);

    return resolved;
  }

  Future<String> prepareFileForShare(
    Post post, {
    void Function(int received, int total)? onProgress,
  }) async {
    final url = _downloadUrl(post);
    if (url == null) {
      throw StateError('No downloadable URL for this post.');
    }
    final fileName = _fileName(post, url);
    final tempDir = await getTemporaryDirectory();
    final shareDir = Directory(p.join(tempDir.path, 'shares'));
    if (!shareDir.existsSync()) {
      shareDir.createSync(recursive: true);
    }
    final filePath = p.join(shareDir.path, fileName);
    if (File(filePath).existsSync() && File(filePath).lengthSync() > 0) {
      return filePath;
    }
    await _dio.download(
      url,
      filePath,
      onReceiveProgress: onProgress,
      options: Options(headers: _headersFor(post)),
    );
    return filePath;
  }

  Future<String?> downloadPost(
    Post post, {
    String? folderTemplate,
    void Function(int received, int total)? onProgress,
  }) async {
    final url = _downloadUrl(post);
    if (url == null) {
      throw StateError('No downloadable URL for this post.');
    }
    final fileName = _fileName(post, url);
    final subDir = folderTemplate != null && folderTemplate.isNotEmpty
        ? resolveSubDir(post, folderTemplate)
        : null;

    if (Platform.isAndroid) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, fileName);
      await _dio.download(
        url,
        tempPath,
        onReceiveProgress: onProgress,
        options: Options(headers: _headersFor(post)),
      );
      final saved = await _channel.invokeMethod<String>('saveToDownloads', {
        'path': tempPath,
        'fileName': fileName,
        'mimeType': _mimeType(fileName, post.fileType),
        if (subDir != null && subDir.isNotEmpty) 'subDir': subDir,
      });
      return saved ?? fileName;
    }

    final downloads =
        await getDownloadsDirectory() ?? await getTemporaryDirectory();
    final targetDir = subDir != null && subDir.isNotEmpty
        ? Directory(p.join(downloads.path, subDir))
        : downloads;
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }
    final savePath = p.join(targetDir.path, fileName);
    await _dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      options: Options(headers: _headersFor(post)),
    );
    return savePath;
  }

  Future<String?> downloadUrl(
    String url, {
    required String fileName,
    String mimeType = 'application/octet-stream',
    bool openAfterDownload = false,
    void Function(int received, int total)? onProgress,
  }) async {
    if (Platform.isAndroid) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, fileName);
      await _dio.download(url, tempPath, onReceiveProgress: onProgress);
      if (openAfterDownload) {
        await openFile(tempPath, mimeType: mimeType);
        return tempPath;
      }
      final saved = await _channel.invokeMethod<String>('saveToDownloads', {
        'path': tempPath,
        'fileName': fileName,
        'mimeType': mimeType,
      });
      return saved ?? fileName;
    }

    final downloads =
        await getDownloadsDirectory() ?? await getTemporaryDirectory();
    final path = p.join(downloads.path, fileName);
    await _dio.download(url, path, onReceiveProgress: onProgress);
    if (openAfterDownload) await openFile(path, mimeType: mimeType);
    return path;
  }

  Future<void> openFile(String path, {String? mimeType}) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod<void>('openFile', {
        'path': path,
        'mimeType': mimeType ?? _mimeType(path, ''),
      });
      return;
    }
    if (Platform.isWindows) {
      await Process.start('explorer.exe', [path]);
      return;
    }
    if (Platform.isLinux) {
      await Process.start('xdg-open', [path]);
    }
  }

  String? _downloadUrl(Post post) {
    return MediaUrlSelector.download(post);
  }

  String _fileName(Post post, String url) {
    final parsed = Uri.tryParse(url);
    final fromUrl = parsed == null ? '' : p.basename(parsed.path);
    if (fromUrl.contains('.') && fromUrl.length > 3) return fromUrl;
    final extension = _extension(post.fileType);
    return '${post.providerId}_${post.id}$extension';
  }

  String _extension(String fileType) {
    final value = fileType.toLowerCase();
    if (value.contains('webm')) return '.webm';
    if (value.contains('mp4') || value.contains('video')) return '.mp4';
    if (value.contains('gif')) return '.gif';
    if (value.contains('png')) return '.png';
    return '.jpg';
  }

  String _mimeType(String fileName, String fileType) {
    final value = '${fileName.toLowerCase()} ${fileType.toLowerCase()}';
    if (value.contains('.webm') || value.contains('webm')) return 'video/webm';
    if (value.contains('.mp4') || value.contains('mp4')) return 'video/mp4';
    if (value.contains('.gif') || value.contains('gif')) return 'image/gif';
    if (value.contains('.png') || value.contains('png')) return 'image/png';
    return 'image/jpeg';
  }

  Map<String, String> _headersFor(Post post) {
    final lower = '${post.providerId} ${post.providerName} '
            '${post.previewUrl} ${post.sampleUrl} ${post.fileUrl}'
        .toLowerCase();
    return {
      'User-Agent': lower.contains('realbooru') || lower.contains('paheal')
          ? 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/125 Mobile Safari/537.36'
          : 'Lunaris/2.0.1 Flutter local booru browser',
      'Accept': lower.contains('realbooru') || lower.contains('paheal')
          ? 'video/webm,video/mp4,image/avif,image/webp,image/apng,image/*,*/*;q=0.8'
          : '*/*',
      if (lower.contains('gelbooru')) 'Referer': 'https://gelbooru.com/',
      if (lower.contains('rule34') && !lower.contains('paheal'))
        'Referer': 'https://rule34.xxx/',
      if (lower.contains('realbooru'))
        'Referer':
            'https://realbooru.com/index.php?page=post&s=view&id=${post.id}',
      if (lower.contains('paheal'))
        'Referer': 'https://rule34.paheal.net/post/view/${post.id}',
    };
  }
}
