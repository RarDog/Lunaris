import 'dart:convert';
import 'package:flutter/material.dart';

enum CloudServiceType {
  googleDrive,
  mega,
  dropbox,
  pixeldrain,
  catbox,
  mediafire,
  bunkr,
  gofile,
  terabox,
  genericVideo,
  other,
}

class CloudMediaLink {
  const CloudMediaLink({
    required this.url,
    required this.service,
    required this.title,
    this.directStreamUrl,
    this.isFolder = false,
    this.isStreamable = false,
    this.detectedPassword,
  });

  final String url;
  final CloudServiceType service;
  final String title;
  final String? directStreamUrl;
  final bool isFolder;
  final bool isStreamable;
  final String? detectedPassword;

  String get serviceName {
    switch (service) {
      case CloudServiceType.googleDrive:
        return 'Google Drive';
      case CloudServiceType.mega:
        return 'MEGA';
      case CloudServiceType.dropbox:
        return 'Dropbox';
      case CloudServiceType.pixeldrain:
        return 'Pixeldrain';
      case CloudServiceType.catbox:
        return 'Catbox';
      case CloudServiceType.mediafire:
        return 'MediaFire';
      case CloudServiceType.bunkr:
        return 'Bunkr';
      case CloudServiceType.gofile:
        return 'GoFile';
      case CloudServiceType.terabox:
        return 'TeraBox';
      case CloudServiceType.genericVideo:
        return 'Direct Video';
      case CloudServiceType.other:
        return 'External Mirror';
    }
  }

  Color get brandColor {
    switch (service) {
      case CloudServiceType.googleDrive:
        return const Color(0xFF4285F4); // Google Blue
      case CloudServiceType.mega:
        return const Color(0xFFD9272E); // Mega Red
      case CloudServiceType.dropbox:
        return const Color(0xFF0061FF); // Dropbox Blue
      case CloudServiceType.pixeldrain:
        return const Color(0xFF00B4D8); // Cyan
      case CloudServiceType.catbox:
        return const Color(0xFFFF6F00); // Amber/Orange
      case CloudServiceType.mediafire:
        return const Color(0xFF1E88E5); // MediaFire Blue
      case CloudServiceType.bunkr:
        return const Color(0xFF9C27B0); // Purple
      case CloudServiceType.gofile:
        return const Color(0xFF26A69A); // Teal
      case CloudServiceType.terabox:
        return const Color(0xFF29B6F6); // Light Blue
      case CloudServiceType.genericVideo:
        return const Color(0xFFE91E63); // Pink
      case CloudServiceType.other:
        return const Color(0xFF78909C); // Slate
    }
  }

  IconData get iconData {
    if (isFolder) return Icons.folder_zip_rounded;
    if (isStreamable || service == CloudServiceType.genericVideo) {
      return Icons.play_circle_filled_rounded;
    }
    switch (service) {
      case CloudServiceType.googleDrive:
        return Icons.add_to_drive_rounded;
      case CloudServiceType.mega:
        return Icons.cloud_circle_rounded;
      case CloudServiceType.dropbox:
        return Icons.cloud_done_rounded;
      case CloudServiceType.pixeldrain:
      case CloudServiceType.catbox:
      case CloudServiceType.mediafire:
      case CloudServiceType.bunkr:
      case CloudServiceType.gofile:
      case CloudServiceType.terabox:
        return Icons.cloud_download_rounded;
      case CloudServiceType.genericVideo:
        return Icons.videocam_rounded;
      case CloudServiceType.other:
        return Icons.link_rounded;
    }
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'service': service.name,
        'title': title,
        if (directStreamUrl != null) 'directStreamUrl': directStreamUrl,
        'isFolder': isFolder,
        'isStreamable': isStreamable,
        if (detectedPassword != null) 'detectedPassword': detectedPassword,
      };

  factory CloudMediaLink.fromJson(Map<String, dynamic> json) {
    final serviceStr = (json['service'] ?? '').toString();
    final service = CloudServiceType.values.firstWhere(
      (e) => e.name == serviceStr,
      orElse: () => CloudServiceType.other,
    );
    return CloudMediaLink(
      url: (json['url'] ?? '').toString(),
      service: service,
      title: (json['title'] ?? '').toString(),
      directStreamUrl: json['directStreamUrl']?.toString(),
      isFolder: json['isFolder'] == true,
      isStreamable: json['isStreamable'] == true,
      detectedPassword: json['detectedPassword']?.toString(),
    );
  }

  String encode() => jsonEncode(toJson());

  static CloudMediaLink? tryDecode(String str) {
    try {
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) {
        return CloudMediaLink.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }
}
