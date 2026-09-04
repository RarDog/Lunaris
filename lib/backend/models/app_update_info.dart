class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.publishedAt,
    this.apkUrl,
    this.apkArm64Url,
    this.apkArmv7Url,
    this.apkX86_64Url,
    this.windowsInstallerUrl,
    this.portableZipUrl,
    this.linuxTarGzUrl,
  });

  final String version;
  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final DateTime? publishedAt;

  /// Generic APK (fat / universal build). Used as a fallback.
  final String? apkUrl;

  /// Per-ABI APKs produced by `flutter build apk --split-per-abi`.
  final String? apkArm64Url;   // app-arm64-v8a-release.apk
  final String? apkArmv7Url;   // app-armeabi-v7a-release.apk
  final String? apkX86_64Url;  // app-x86_64-release.apk

  final String? windowsInstallerUrl;
  final String? portableZipUrl;
  final String? linuxTarGzUrl;

  /// Returns the best APK URL for [abi], falling back to the generic APK.
  String? apkUrlForAbi(String abi) {
    if (abi.contains('arm64') || abi == 'arm64-v8a') {
      return apkArm64Url ?? apkUrl;
    }
    if (abi.contains('x86_64')) {
      return apkX86_64Url ?? apkUrl;
    }
    // armeabi-v7a and everything else
    return apkArmv7Url ?? apkArm64Url ?? apkUrl;
  }

  bool get hasAssets =>
      apkUrl != null ||
      apkArm64Url != null ||
      apkArmv7Url != null ||
      apkX86_64Url != null ||
      windowsInstallerUrl != null ||
      portableZipUrl != null ||
      linuxTarGzUrl != null;
}
