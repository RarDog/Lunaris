const lunarisChangelog = [
  LunarisChange(
    version: '2.3.1',
    title: 'Cloud Mirrors & Author Announcements Fixes',
    bullets: [
      'Collapsible Cloud Mirrors: the cloud drives section is now folded by default into a sleek header card matching the Tags and Comments cards, expandable on tap.',
      'Tag Panel Sanitation: filtered out cloud drive links, JSON metadata, and URLs from appearing in the post tags panel and tag counters.',
      'Author Announcements HTML Cleaning: stripped all raw <p style="">, <strong>, and formatting artifacts from artist announcements, rendering clean readable text and clickable service link chips.',
    ],
  ),
  LunarisChange(
    version: '2.3.0',
    title: 'Artist Cloud Drives & External Video Mirrors',
    bullets: [
      'Cloud Mirrors & Drives: automatic detection and parsing of external links to Google Drive, MEGA, Dropbox, Pixeldrain, Catbox, MediaFire, GoFile, Bunkr, and direct video files from post descriptions, HTML, and embed data.',
      'Direct Video Playback & Download: resolves direct streaming URLs for Dropbox (?raw=1), Google Drive, Pixeldrain API, and Catbox with 1-tap playback and direct downloads.',
      'Cloud Mirrors Card: styled cards with service branding colors (MEGA Red, Google Drive Blue, Dropbox Blue, Pixeldrain Cyan) showing link type, direct stream button, external open, and copy link.',
      'Link-Only Posts Support: artist posts that only contain cloud drive links without direct server files are now displayed with an elegant CloudMediaHero banner instead of an empty view.',
      'Archive Password Detection: automatically extracts and displays archive passwords (Pass: ..., Password: ...) with 1-tap copy button.',
      'Artist Commentary Card: formatted display of author notes, instructions, and text below post details.',
    ],
  ),
  LunarisChange(
    version: '2.2.0',
    title: 'Offline Mode Overhaul & Post Details Screen Redesign',
    bullets: [
      '100% Genuine Offline Playback: local images and videos play directly from disk storage via media_kit and cached files without initiating network requests.',
      'Offline Storage & Sync Hub: live storage size indicator (💾 X.X MB/GB on device), 1-tap "Download all missing" batch sync button, real-time downloading task progress bar, and sorting (by date, size, artist).',
      'Action Dock 2.0: redesigned post action bar with primary dock buttons (Like, Download with status/progress, Collection, Share) and clean "More" modal bottom sheet for secondary actions.',
      'Modern Post Info Card: author row with palette icon and clickable search, booru provider badge with relative timestamp, spec capsules (resolution, file format, safety rating badge, score, offline size).',
      'Unified Neighbor Strip & Tags Card: post neighbor thumbnail strip now available on both mobile and desktop, alongside modern rounded tag blocks and chat-bubble comments.',
    ],
  ),
  LunarisChange(
    version: '2.1.0',
    title: '4-Tab Major Redesign: Search, Favorites, History & Collections',
    bullets: [
      'Search Tab Redesign: hero search container, quick search operator chips (and, type:video, rating:safe, etc.), interactive recent search cloud with 1-tap delete (x), popular exploratory category cards, and search tips cheat sheet.',
      'Favorites Tab Redesign: live counters on segment tabs (All, Offline, Artists), quick media filter chips (All, Videos, Images), in-favorites search bar, and Spotify/Apple Music-style artist album cards with 3-thumbnail preview collages.',
      'History Tab Redesign: timeline grouped by time (Today, Yesterday, Date), view mode switcher (rich list with 68x68 rounded thumbnails, provider chips, timestamps, and delete from history vs full visual Masonry gallery grid), and confirmation dialog before clearing.',
      'Collections Tab Redesign: Pinterest-style collection cards with 2x2 thumbnail mosaic covers and glassmorphism post counters, modernized collection details screen with description banner, and elegant squircle creation dialog.',
    ],
  ),
  LunarisChange(
    version: '2.0.15',
    title: 'Settings 2.0 Layout Fixes & Pinned Quick Navigation',
    bullets: [
      'Fixed vertical text wrapping on mobile: separated title and full-width SegmentedButtons for Theme, Language, and Media Quality so text never collapses.',
      'Pinned Category Quick Navigation: bar now stays at the top of the screen and reliably scrolls to all 7 sections.',
      'SingleChildScrollView Migration: ensures all section keys remain mounted and scrollable on demand.',
      'Full-width Folder Structure Tile: added clean monospace path card with dedicated change button.',
      'Header text overflow protections: wrapped title texts in Expanded across all settings cards.',
    ],
  ),
  LunarisChange(
    version: '2.0.14',
    title: 'Settings 2.0: Modern Grouped Design & Quick Ergonomics',
    bullets: [
      'Settings 2.0 Layout: reimagined settings experience with modern squircle card groups, smooth borders, and curated accent badges.',
      'Category Quick Navigation: horizontal capsule strip at the top to smoothly jump between General, Appearance, Feed, Filters, Storage, Diagnostics, and About.',
      'Instant Segmented Controls: replaced tedious dropdowns with fast 1-tap SegmentedButtons for Theme (Dark/Light/Auto), Language (RU/EN), and Media Quality (Auto/Data saver/HQ).',
      'Folder Structure Bottom Sheet: intuitive download directory template picker with preset chips and custom pattern editor.',
      'Interactive Stepper & Limit Controls: modernized desktop & mobile column steppers and disk cache limits with accent pill badges.',
      'Hero Brand Banner: polished app presentation card in About section with glowing icon, version build badge, update checker, and Gitea repository link.',
    ],
  ),
  LunarisChange(
    version: '2.0.13',
    title: 'Toolbar Section Dividers & Post Card Badge Stacking Fix',
    bullets: [
      'Toolbar Section Dividers: added subtle vertical dividers between Actions (Reset/Refresh), Rating, Providers, and Top Periods to prevent visual clutter.',
      'Post Card Badge Deconfliction: moved Rating badge (Explicit/Questionable/Safe) to the bottom-left beneath the Seen/Downloaded indicators.',
      'Separated Provider & Media Badges: booru source (e.g. Gelbooru) remains top-left and Video/GIF badge remains top-right, preventing them from overlapping on narrow screens.',
      'Expanded Bottom Gradient: increased bottom cinematic gradient height to 64dp for clean text and badge contrast.',
    ],
  ),
  LunarisChange(
    version: '2.0.12',
    title: 'Feed 2.0: Pinterest Modern Redesign & Sleek Cards',
    bullets: [
      'Feed 2.0 Design: modern squircle post cards with 14dp border radius, subtle micro-borders, and depth shadows.',
      'Unified Media Badges: sleek glassmorphism capsules for booru providers, ratings, video/GIF indicators, and status badges.',
      'Cinematic Bottom Gradient: gentle shading on post cards for clean presentation without obscuring art.',
      'Tactile Floating Favorite Button: circular glassmorphism heart button with neon glow and instant feedback.',
      'Compact 2-Tier Feed Toolbar: 22dp search capsule, filter count badge, and single unified horizontal scroll for sources and time periods.',
      'Quick Filter & Actions: direct access to random post, selection mode, rating picker, and active filter resets.',
      'Polished Search Presets: stylish bookmark capsules for quick access to saved search queries.',
    ],
  ),
  LunarisChange(
    version: '2.0.11',
    title: 'Mobile Video Player Redesign & Format Recognition Fix',
    bullets: [
      'Fixed "Failed to recognize file format" error on initial video load by providing synchronous Referer headers and automatic retry.',
      'Modern Mobile Video Player: cinematic top and bottom gradient glassmorphism overlays with immersive controls.',
      'Double-Tap Seek: double-tap left side to seek -10s, right side to seek +10s with glowing ripple animations.',
      'Hold for 2X Speed Boost: press and hold video to temporarily play at 2.0x with glowing badge, release to resume regular speed.',
      'Vertical Volume Swipe: swipe up/down on the right half of the screen to adjust player volume with a floating badge.',
      'Playback Speed Selector: quick chip button supporting 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x speeds.',
      'Screen Lock Mode: lock player controls with one tap to prevent accidental touches during video watching.',
      'Sleek Neon Seekbar with live network buffer progress indicator.',
    ],
  ),
  LunarisChange(
    version: '2.0.10',
    title: 'Fix "and" Tag Operator Retention, Suggestion Preceding Drafts & AND Chip Styling',
    bullets: [
      'Fixed "and" operator disappearing when submitting search or applying autocompletions.',
      'Preserved preceding draft tokens (e.g. typing "cat and d" then picking "dog" now retains "cat", "AND", and "dog").',
      'Supported multiple "and" separators without accidental deduplication.',
      'Distinct visual styling for AND separator chips with secondary theme container and alt-route icon.',
    ],
  ),
  LunarisChange(
    version: '2.0.9',
    title: 'Instant Tag Suggestions, Persistent Disk Cache, Expanded History & Match Highlighting',
    bullets: [
      'Instant 0ms tag suggestions: cached tags and search history are served immediately without network delay.',
      'Persistent disk cache: tag suggestions are preserved in lunaris_tag_cache.json across app restarts on Android and PC.',
      'Debounce reduced from 530ms to 100ms+160ms for ultra-responsive typing.',
      'Match highlighting: matched characters are bolded and highlighted with the primary theme color in the dropdown.',
      'Vibrant category badges: distinct colors for Artist (red), Character (green), Copyright (purple), Species (blue), and Meta (grey).',
      'Danbooru tag autocomplete support connected (/tags/autocomplete.json).',
      'Configurable search history limit (up to 2000 items) and tag cache limit (up to 20000 tags) in Settings.',
      'Dedicated Clear Tag Cache actions in Settings and Cache Manager.',
    ],
  ),
  LunarisChange(
    version: '2.0.8',
    title: 'Shared Context Modifiers for Multi-Tag Search & Clean Tag Filtering',
    bullets: [
      'Trailing context modifiers: typing "cat and dog anthro" automatically distributes "anthro" to all "and" branches (cat anthro + dog anthro).',
      'Optional grouping parenthesis support: e.g. "(cat and dog) anthro".',
      'Resolved "No posts yet" bug by adapting client post validation to multi-tag stream groups and stripping operator keywords from booru queries.',
    ],
  ),
  LunarisChange(
    version: '2.0.7',
    title: 'Independent Multi-Tag Search Streams, Local "and" Connector, Pawchive in Main Feed & Reverts',
    bullets: [
      'Independent multi-tag search: separate tags query providers individually and interleave results so each tag brings its own content without mutual exclusion.',
      'Local "and" tag connector: typing "and" between tags groups them into a strict intersection query (e.g. "genshin and raiden").',
      'Enabled Pawchive in the main feed alongside Rule34, Gelbooru, e621, and Realbooru.',
      'Restored instantaneous client-side media type filtering in artist posts.',
      'Removed external linked accounts bar from artist posts screen.',
    ],
  ),
  LunarisChange(
    version: '2.0.6',
    title: 'Pawchive Deep Integration: Global Posts Feed, Artist Tags, Announcements, Links & Server Media Filter',
    bullets: [
      'Connected Pawchive global recent posts (/api/v1/posts) to the main Feed screen with search.',
      'Interactive artist tags bar (/tags) with live post counts (#tag (N)) and instant topic filtering.',
      'Linked accounts bar (/links) with direct navigation to author profiles across platforms.',
      'Artist announcements modal (/announcements) showing creator news, dates and status updates.',
      'Server-side media filtering (Photos, Videos, GIFs) querying the entire author archive through the API.',
    ],
  ),
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
