const ruleGelChangelog = [
  RuleGelChange(
    version: '1.0.2',
    title: 'Realbooru safety fix',
    bullets: [
      'Realbooru stays available in Providers, but is disabled by default while its public DAPI is offline.',
      'Provider diagnostics now surface the Realbooru API reason instead of a generic exception.',
      'Existing enabled Realbooru configs are disabled on startup so the main feed is not polluted by a known-offline API.',
    ],
  ),
  RuleGelChange(
    version: '1.0.1',
    title: 'Realbooru and mobile polish',
    bullets: [
      'Added Realbooru as a default enabled provider.',
      'Startup update checks now look for new Gitea releases every launch.',
      'Refresh-rate controls are Android-only; desktop keeps stable app motion.',
      'Tag chip input no longer jumps while typing.',
    ],
  ),
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
