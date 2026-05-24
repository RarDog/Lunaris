class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.publishedAt,
    this.apkUrl,
    this.windowsInstallerUrl,
  });

  final String version;
  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final DateTime? publishedAt;
  final String? apkUrl;
  final String? windowsInstallerUrl;

  bool get hasAssets => apkUrl != null || windowsInstallerUrl != null;
}
