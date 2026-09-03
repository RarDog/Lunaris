const lunarisChangelog = [
  LunarisChange(
    version: '2.0.5',
    title: '10 QoL Super-Update: AMOLED, Dynamic Colors, Grid switch, Share, Presets, Cache & Backup',
    bullets: [
      'AMOLED Pure Black theme (#000000) for OLED battery saving.',
      'Material You dynamic color support on Android matching system wallpaper.',
      'Grid layout mode switcher in the feed toolbar: Masonry, 1:1 Square Grid, and List.',
      'Swipe down to dismiss and double-tap with animated heart overlay to favorite.',
      'Direct file sharing (Share sheet) from post details.',
      'Saved search presets with instant filtering and bookmark creation.',
      'Smart download folder template support ({Artist}, {Provider}, {Service}, {ID}, {Date}).',
      'Interactive Cache Manager screen with detailed storage breakdown and selective cleanup.',
      'Full JSON backup export and import for seamless configuration sync.',
    ],
  ),
  LunarisChange(
    version: '2.0.4',
    title: 'Platform service selection & media type filtering in artist posts',
    bullets: [
      'Added multi-select platform filters (Patreon, Pixiv Fanbox, Fantia, Boosty, Discord) in the Artists tab.',
      'Added multi-select media type filter chips (Photos, Videos, GIFs) in artist posts with counts.',
      'Full-screen post pager respects active media type filters during swiping.',
    ],
  ),
  LunarisChange(
    version: '2.0.3',
    title: 'Infinite artist pagination, favorite artists modal, and card layout polish',
    bullets: [
      'Implemented infinite scroll pagination in the artist post feed — now loads all historical works endlessly as you scroll.',
      'Moved favorite artists to a compact star action button in the top-right header that opens an interactive modal.',
      'Expanded artist card vertical height so updated dates and statistics are never cut off.',
      'Removed mapping truncation in Pawchive provider to deliver all post attachments cleanly.',
    ],
  ),
  LunarisChange(
    version: '2.0.2',
    title: 'Swipeable media pager, favorite artists, performance and Pawchive',
    bullets: [
      'Full horizontal post pager across mobile and desktop in Feed, Artists, Favorites, Collections, and Viewed history.',
      'Eliminated video preview stutter and lag in grid feed by using high-performance cached thumbnails and on-demand playback.',
      'Added favorite artists bar at the top of the Artists tab with quick access and recent photos/videos stream.',
      'Multi-image posts now feature an in-post navigation indicator with image switching.',
      'New Pawchive provider support and cleaned up deprecated providers.',
      'In-app update checks and downloads connected directly to RarDog Gitea releases.',
    ],
  ),
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
    title: 'Lunaris rebrand and providers',
    bullets: [
      'RuleGel is now Lunaris while keeping the same package identity for updates.',
      'Xbooru was added as a default Gelbooru-compatible provider.',
      'Rule34 Paheal is available as an HTML provider.',
      'Video player UI preferences are saved across fullscreen, details and restarts.',
    ],
  ),
  LunarisChange(
    version: '1.0.2',
    title: 'Provider safety fix',
    bullets: [
      'Known-offline legacy providers are disabled on startup.',
      'Provider diagnostics now surface API reasons instead of generic exceptions.',
      'Existing enabled legacy configs are disabled so the main feed is not polluted by known-offline APIs.',
    ],
  ),
  LunarisChange(
    version: '1.0.1',
    title: 'Mobile polish',
    bullets: [
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
