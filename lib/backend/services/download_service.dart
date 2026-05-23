import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/post.dart';

class DownloadService {
  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  static const _channel = MethodChannel('rulegel/downloads');

  final Dio _dio;

  Future<String?> downloadPost(
    Post post, {
    void Function(int received, int total)? onProgress,
  }) async {
    final url = _downloadUrl(post);
    if (url == null) {
      throw StateError('No downloadable URL for this post.');
    }
    final fileName = _fileName(post, url);
    if (Platform.isAndroid) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, fileName);
      await _dio.download(url, tempPath, onReceiveProgress: onProgress);
      final saved = await _channel.invokeMethod<String>('saveToDownloads', {
        'path': tempPath,
        'fileName': fileName,
        'mimeType': _mimeType(fileName, post.fileType),
      });
      return saved ?? fileName;
    }

    final location = await getSaveLocation(suggestedName: fileName);
    if (location == null) return null;
    await _dio.download(url, location.path, onReceiveProgress: onProgress);
    return location.path;
  }

  String? _downloadUrl(Post post) {
    for (final url in [post.sampleUrl, post.fileUrl, post.previewUrl]) {
      if (url.trim().isNotEmpty) return url;
    }
    return null;
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
}
