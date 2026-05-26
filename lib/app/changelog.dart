const lunarisChangelog = [
  LunarisChange(
    version: '2.0.1',
    title: 'Localization, zoom and favorite downloads',
    bullets: [
      'Russian and English UI labels were expanded across the main screens and settings.',
      'Mobile image details now support pinch and double-tap zoom without restoring desktop wheel zoom.',
      'Provider chips in the feed update immediately and debounce network reloads to avoid stale results.',
      'Feed previews choose smarter URLs and cache widths for cleaner high-quality thumbnails.',
      'Favorites can optionally auto-download media in the background, with local files tracked separately from favorites.',
    ],
  ),
  LunarisChange(
    version: '2.0.0',
    title: 'Customization and provider polish',
    bullets: [
      'Settings now include app customization: accent color, language, visible tabs and beta update channel.',
      'The Artists tab disappears automatically when Kemono and Coomer are disabled.',
      'All-provider feed mixing is more natural instead of provider-by-provider blocks.',
      'Post cards use wider aspect ranges so images, GIFs and videos leave less empty space.',
      'Kemono and Coomer creator search uses the current mbahArip keyword endpoints with public API fallbacks.',
    ],
  ),
  LunarisChange(
    version: '1.1.2',
    title: 'Experimental tag and Artists update',
    bullets: [
      'Details tags now use category blocks with wrapping chips again.',
      'Gelbooru-compatible providers can enrich tag categories when their tag API exposes metadata.',
      'Kemono and Coomer Artists use improved creator search and public API fallbacks.',
      'This is an experimental release for checking the new tag and Artists behavior.',
    ],
  ),
  LunarisChange(
    version: '1.1.1',
    title: 'Artists and in-app updates',
    bullets: [
      'Disabled providers now disappear from feed chips, search suggestions and feed loading immediately.',
      'Kemono and Coomer are available as a separate Artists flow, without mixing into the normal booru feed.',
      'Update dialogs can download and open the APK or Windows installer directly from the app.',
      'Tag input keeps its scroll position steadier while typing and committing chips.',
    ],
  ),
  LunarisChange(
    version: '1.1.0',
    title: 'Lunaris rebrand and CosBooru',
    bullets: [
      'RuleGel is now Lunaris while keeping the same package identity for updates.',
      'CosBooru now uses the working Danbooru-compatible API at cos.lycore.co.',
      'Xbooru was added as a default Gelbooru-compatible provider.',
      'Rule34 Paheal was removed from providers.',
      'Video player UI preferences are saved across fullscreen, details and restarts.',
    ],
  ),
  LunarisChange(
    version: '1.0.2',
    title: 'Realbooru safety fix',
    bullets: [
      'Realbooru stays available in Providers, but is disabled by default while its public DAPI is offline.',
      'Provider diagnostics now surface the Realbooru API reason instead of a generic exception.',
      'Existing enabled Realbooru configs are disabled on startup so the main feed is not polluted by a known-offline API.',
    ],
  ),
  LunarisChange(
    version: '1.0.1',
    title: 'Realbooru and mobile polish',
    bullets: [
      'Added Realbooru as a default enabled provider.',
      'Startup update checks now look for new Gitea releases every launch.',
      'Refresh-rate controls are Android-only; desktop keeps stable app motion.',
      'Tag chip input no longer jumps while typing.',
    ],
  ),
  LunarisChange(
    version: '1.0.0',
    title: 'Stable 1.0',
    bullets: [
      'Local hide-post organization for posts you do not want in the feed.',
      'Diagnostics report and local log copy tools in Settings.',
      'Cleaner release metadata and maintenance tools for troubleshooting.',
      'Windows portable package is published alongside APK and installer.',
    ],
  ),
  LunarisChange(
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

class LunarisChange {
  const LunarisChange({
    required this.version,
    required this.title,
    required this.bullets,
  });

  final String version;
  final String title;
  final List<String> bullets;
}
