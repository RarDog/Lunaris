const lunarisChangelog = [
  LunarisChange(
    version: '3.0.7',
    title: 'Liquid Glass Navigation Bar — парящая стеклянная панель и анимированная пилюля',
    bullets: [
      'Парящая панель Liquid Glass: нижняя панель навигации преобразована в парящий стеклянный док со скруглением, полупрозрачным градиентом и размытием фона (BackdropFilter blur).',
      'Плавающая пилюля-индикатор (Liquid Pill): плавный анимированный бегунок перетекает под активную вкладку со сглаженной пружинящей физикой (easeOutBack).',
      'Микроанимации нажатия и тактильный отклик: иконки мягко сжимаются при тапе и отпружинивают назад с легким тактильным виброоткликом (Haptic Feedback).',
      'Глубина контента: контент ленты, поиска и галереи плавно просвечивает и размывается под стеклянной панелью при прокрутке.',
    ],
  ),
  LunarisChange(
    version: '3.0.6',
    title: 'Улучшение недавних запросов и отображения тегов',
    bullets: [
      'Полная видимость тегов и запросов: сняты тесные ограничения ширины (140px), теги и поисковые запросы теперь отображаются целиком без усечения.',
      'Устранение дубликатов в истории: автоматическая дедупликация поисковых запросов в базе данных и интерфейсе. Устранены повторяющиеся пары запросов с пустыми счетчиками.',
      'Исправление заголовка карточки поиска: заголовок «Недавние запросы» и счетчик больше не обрезаются на экранах смартфонов.',
      'Удобное удаление: увеличенная область нажатия для кнопки удаления (крестика) предотвращает случайные нажатия на сам запрос.',
    ],
  ),
  LunarisChange(
    version: '3.0.5',
    title: 'Интерактивные ссылки на соцсети и авторов в объявлениях и описаниях',
    bullets: [
      'Кликабельные ссылки в объявлениях автора и описании постов: все URL в тексте подсвечиваются и открываются во внешнем браузере по клику.',
      'Красивые бейджи соцсетей (CreatorLinkChips): автоматическое распознавание и стилизация ссылок на YouTube, X (Twitter), Instagram, TikTok, Discord, Patreon, Fanbox, Fantia, Boosty, Pixiv, Twitch, Telegram, Gumroad и другие платформы с фирменными иконками и цветами.',
      'Корректная очистка пунктуации: знаки препинания в конце URL (!, ?, :, ., ,, ;, >) больше не ломают ссылки.',
    ],
  ),
  LunarisChange(
    version: '3.0.0',
    title: 'Lunaris 3.0 — Глобальное обновление: Дизайн 2.0, Интеграция Pawchive и умная синхронизация',
    bullets: [
      'Дизайн 2.0 (Modern Booru Experience): обновлённый современный интерфейс в стиле Material 3, адаптивные сетки галереи (Masonry / Staggered), улучшенная типографика и плавные микроанимации.',
      'Полноэкранный видеоплеер нового поколения: умный автоматический поворот экрана в ландшафтную ориентацию для горизонтальных видео и быстрый ручной переключатель ориентации в одно касание.',
      'Новая архитектура поиска (OverlayPortal): подсказки тегов отображаются через нативный портал Flutter без блокировки кнопок панели, очистки и сброса фильтров.',
      'Pawchive 2.0 & Двусторонняя синхронизация: подключение аккаунтов через логин/пароль или Session Cookie, импорт избранного с сервера, экспорт локальных коллекций в аккаунт на сервере и сквозная синхронизация со всех поддерживаемых платформ.',
      'Ленивое автоопределение разрешения: фоновый декодер автоматически рассчитывает и выводит точные размеры медиа (например, 1920 × 1080) для постов Pawchive без серверных метаданных.',
      'Умные per-ABI обновления: автообновление через GitHub скачивает точный APK под архитектуру вашего процессора (arm64-v8a, armeabi-v7a, x86_64), сокращая вес загрузки.',
      'Исправление вёрстки: устранены переносы текста в заголовке окна аккаунтов и карточках пользователей на экранах смартфонов.',
    ],
  ),
  LunarisChange(
    version: '2.3.10',
    title: 'Выгрузка локального избранного в Pawchive и двусторонняя синхронизация',
    bullets: [
      'Экспорт локального избранного: добавлена возможность выгрузить всех ваших локальных авторов из приложения прямо в аккаунт Pawchive на сервере в 1 клик.',
      'Двусторонняя синхронизация: переключатель двусторонней синхронизации объединяет коллекции — скачивает новых авторов с сервера и отправляет локальных на сервер Pawchive.',
      'Кнопка выгрузки в карточке аккаунта: быстрая кнопка со стрелкой вверх и пункт контекстного меню «Выгрузить в Pawchive» для любого подключённого аккаунта.',
      'Синхронизация в реальном времени с любых провайдеров: при добавлении автора в избранное в лентах Kemono, Coomer или Pawchive изменение мгновенно передаётся на сервер Pawchive.',
    ],
  ),
  LunarisChange(
    version: '2.3.9',
    title: 'Исправление входа и синхронизации аккаунтов Pawchive',
    bullets: [
      'Исправлены API эндпоинты Pawchive: пути запросов избранных авторов и управления подписками приведены в соответствие со спецификацией API v1 (/api/v1/account/favorites, /api/v1/favorites/creator/...).',
      'Устранена ошибка 404: авторизация по логину и паролю, а также по session cookie теперь успешно завершается и сразу синхронизирует всех авторов.',
      'Информативные ошибки: понятные сообщения на русском при неверном пароле или сбое сети вместо сырых исключений Dio.',
    ],
  ),
  LunarisChange(
    version: '2.3.8',
    title: 'ABI-Aware Auto-Update — правильный APK для вашего процессора',
    bullets: [
      'Определение архитектуры Android: приложение читает Build.SUPPORTED_ABIS (arm64-v8a, armeabi-v7a, x86_64) через нативный канал.',
      'Точный APK из GitHub: при обновлении скачивается per-ABI APK (app-arm64-v8a-release.apk и т.д.), а не один общий файл.',
      'Fallback: нет per-ABI APK → универсальный APK → страница релиза в браузере.',
      'Кеш ABI: архитектура определяется один раз за сеанс.',
    ],
  ),
  LunarisChange(
    version: '2.3.7',
    title: 'Lazy Media Dimensions for Pawchive & Unknown-Size Providers',
    bullets: [
      'Auto-Resolve Image Dimensions: when a provider (such as Pawchive) does not supply width/height metadata, the app now lazily resolves the real pixel dimensions by decoding the image in the background and displays them as soon as they are ready.',
      'No More "0 × 0": the resolution badge now shows "… × …" while dimensions are being fetched, and the correct resolution (e.g. 1920 × 1080) once decoded. The badge is hidden entirely for video/link posts where dimensions cannot be resolved.',
      'Session Cache: resolved image dimensions are cached in memory for the lifetime of the app so repeated visits to the same post do not trigger re-downloads.',
    ],
  ),
  LunarisChange(
    version: '2.3.6',
    title: 'Pawchive Accounts Integration & Favorites Synchronization',
    bullets: [
      'Pawchive Account Support: users can now log into Pawchive with their username and password or paste a direct session cookie.',
      'Multi-Account Synchronization: add and manage multiple Pawchive accounts; synchronize favorite artists from all connected accounts into a consolidated local favorites list with 1 tap.',
      'Real-Time Remote Favorites Sync: favoriting or unfavoriting any Pawchive artist in the app automatically pushes the change to the active Pawchive account in real time.',
      'Artist Posts Direct Favorite: added a star toggle directly in the artist posts screen top bar to add or remove creators from favorites without leaving their gallery.',
      'Dedicated UI & Quick Access: manage connected accounts, view sync stats, and trigger synchronization from the Artists screen, Favorites modal, and Settings screen.',
    ],
  ),
  LunarisChange(
    version: '2.3.5',
    title: 'Fullscreen Video Auto-Rotation & Orientation Controls',
    bullets: [
      'Smart Fullscreen Auto-Rotation: entering fullscreen mode on horizontal/landscape videos automatically snaps the device into landscape orientation for maximum viewing area, while vertical/portrait videos stay in portrait mode.',
      'Manual Orientation Toggle: added a quick-access rotation button (Icons.screen_lock_portrait / landscape) directly in the fullscreen top bar next to the close button, allowing 1-tap switching between landscape and portrait.',
      'Clean Orientation Recovery: exiting fullscreen seamlessly restores system navigation bars (Edge-to-Edge) and restores unrestricted device sensor orientations.',
    ],
  ),
  LunarisChange(
    version: '2.3.4',
    title: 'OverlayPortal Architecture & Search UI Unblocking',
    bullets: [
      'OverlayPortal Migration: replaced manual root OverlayEntry and translucent backdrop with Flutter native OverlayPortal and TapRegion. Completely eliminates ghost overlay leaks and touch interception.',
      'Unblocked Toolbar & Search Bar GUI: buttons (Refresh / Обновить, Clear Filters / Сбросить, random post, filter chips) and search chip crosses now respond immediately to taps without being swallowed by overlay backdrops.',
      'Instant Chip Removal: deleting a tag chip (via its X cross icon) now updates the search immediately in real time, synchronizing the feed without restoring deleted tags on rebuild.',
      'Search Clear Synchronization: tapping the search bar clear button (X) resets the query and clears active filters immediately.',
      'Non-Blocking Outside Tap: tapping outside the suggestion dropdown smoothly dismisses suggestions while allowing the touch event to pass through directly to the underlying button or post.',
    ],
  ),
  LunarisChange(
    version: '2.3.3',
    title: 'Tag Suggestions Overlay Fix & Rule34 API Alignment',
    bullets: [
      'Tag Suggestions Hanging Fix: eliminated the bug where the tag suggestion card remained stuck on screen after clearing text or tapping outside. Added immediate dismissal on empty input, outside-tap backdrop dismissal, controller listener, and unfocus on submission.',
      'Rule34 Dedicated Autocomplete: connected Rule34 directly to its official fast /autocomplete.php?q= endpoint, displaying real-time tag suggestions with accurate post counts (e.g. braid (216,984)).',
      'Rule34 Tag Types (fields=tag_info): added tag_info field to post query for accurate tag categories per post.',
      'Rule34 Authentication & Outage Handling: added detection for "missing authentication", rate limits, and server overload/search down ("success": false) with informative guidance to enter API Key & User ID.',
    ],
  ),
  LunarisChange(
    version: '2.3.2',
    title: 'Gelbooru DAPI Compliance & Tag Query Optimization',
    bullets: [
      'Official Gelbooru DAPI Alignment: fixed tag suggestions pattern to use SQL LIKE wildcard (%) instead of literal asterisk (*), restoring accurate tag autocompletion.',
      'Popularity Tag Sorting: added orderby=count and order=DESC to Gelbooru tag search so the most relevant and widely used tags appear first.',
      'Batch Tag Categorization: migrated post tag metadata queries to the official "names" parameter, resolving categories for up to 80 tags in a single batch request instead of dozens of sequential requests.',
      'Throttling & Auth Guidance: enhanced API credentials helper text and informative error messages with direct instructions to configure API Key & User ID from Gelbooru account options.',
    ],
  ),
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
      'Hero Brand Banner: polished app presentation card in About section with glowing icon, version build badge, update checker, and GitHub repository link.',
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
      'In-app update checks and downloads connected directly to RarDog GitHub releases.',
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
      'Startup update checks now look for new GitHub releases every launch.',
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
