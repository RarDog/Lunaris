const ruleGelChangelog = [
  RuleGelChange(
    version: '1.0.0',
    title: 'Stable 1.0',
    bullets: [
      'Local hide-post organization for posts you do not want in the feed.',
      'Diagnostics report and local log copy tools in Settings.',
      'Cleaner release metadata and maintenance tools for troubleshooting.',
      'Windows portable package is published alongside APK and installer.',
    ],
  ),
  RuleGelChange(
    version: '0.4.3',
    title: 'Bugfixes',
    bullets: [
      'Fixed video play/retry controls.',
      'Fixed tag chip input and tag navigation from details.',
      'Fixed collection deletion persistence.',
      'Settings export now includes blacklist and whitelist data.',
    ],
  ),
];

class RuleGelChange {
  const RuleGelChange({
    required this.version,
    required this.title,
    required this.bullets,
  });

  final String version;
  final String title;
  final List<String> bullets;
}
