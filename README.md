<p align="center">
  <strong>English</strong> • <a href="README_RU.md">Русский</a>
</p>

# 💎 Prisma

<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="128" height="128" alt="Prisma Logo" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.35);" />
</p>

<p align="center">
  <strong>A modern, next-generation cross-platform client for Booru imageboards and Creator archives</strong><br>
  Smooth Pinterest-style masonry feed, Pawchive 2.0 two-way synchronization, intelligent in-app updates, dynamic aspect ratio detection, and buttery-smooth media playback.
</p>

<p align="center">
  <a href="https://github.com/RarDog/Prisma/releases"><img src="https://img.shields.io/badge/Version-3.5.2-8A2BE2?style=for-the-badge&logo=semver&logoColor=white" alt="Version 3.5.2" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Linux%20%7C%20Windows%20%7C%20macOS-00C853?style=for-the-badge" alt="Platforms" />
  <a href="https://github.com/RarDog/Prisma/wiki"><img src="https://img.shields.io/badge/Wiki-Documentation-FF6F00?style=for-the-badge&logo=gitbook&logoColor=white" alt="Wiki" /></a>
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License MIT" />
</p>

---

## 🚀 What's New in Prisma 3.5

### 🎨 Design 2.0 & Interface Optimization
- **Modern Visual Style**: Squircle cards, adaptive dynamic Material You color palette, and refined glassmorphic surfaces.
- **Intelligent Action Dock 2.0**: Compact quick-action dock placed beneath posts for one-tap downloading, sharing, tag inspection, and source viewing.
- **Smooth Animations & Micro-Interactions**: Hero media transitions, interactive drag gestures, and animated double-tap likes.
- **Keyboard-Adaptive Layout**: Floating action buttons and navigation dock automatically minimize when the on-screen keyboard appears; search lists support dismiss-on-scroll.

### 🐾 Deep Pawchive 2.0 Integration
- **Flexible Authentication**: Sign in via username/password or direct `Session Cookie`.
- **Two-Way Synchronization**: Automatically synchronize your favorites between Prisma's local database and your Pawchive account. Local creators can be pushed to the server with a single tap.
- **Instant Cloud Sync**: Favoriting any creator across Patreon, Fanbox, Fantia, Boosty, Gumroad, DLsite, or Discord synchronizes with the server in real-time.

### 🎬 Smart Media Player & Dimension Detection
- **Lazy Dimension Resolution**: Instant 1920×1080 (and custom) aspect-ratio discovery without needing to pre-download large media files.
- **Fullscreen Auto-Orientation**: Video player automatically adjusts screen orientation (landscape or portrait) to match the media's native aspect ratio.

### 📦 Split APKs & ABI-Aware Auto-Updates
- Optimized per-ABI APK builds (`arm64-v8a`, `armeabi-v7a`, `x86_64`) for drastically reduced package sizes.
- Built-in update engine automatically detects the device CPU architecture and fetches only the required binary.

---

## 📚 Documentation & User Guides

Comprehensive illustrated documentation is available in the **[Prisma Wiki](https://github.com/RarDog/Prisma/wiki)**:

- 🚀 **[Getting Started & Installation](docs/wiki/Getting-Started.md)** — Selecting the proper APK for your device architecture, running on Linux, Windows, or macOS.
- 🌐 **[Content Providers](docs/wiki/Providers.md)** — Using Booru sources (Gelbooru, Rule34, Realbooru, e621) and Pawchive creator archives.
- 🔍 **[Smart Search & Tags](docs/wiki/Search-and-Tags.md)** — `and` operators, syntax modifiers, and 0 ms autocomplete.
- 🐾 **[Pawchive Integration](docs/wiki/Pawchive-Sync.md)** — Login, session cookies, two-way sync, and creator cloud exports.
- 🎬 **[Media Viewer & Player](docs/wiki/Media-Viewer.md)** — Gesture navigation, automatic rotation, and Action Dock 2.0.
- 💾 **[Offline Mode & Downloads](docs/wiki/Offline-and-Downloads.md)** — Sync Hub, directory naming templates, and original quality preservation.
- 🛡️ **[Safety & Blacklist](docs/wiki/Safety-and-Blacklist.md)** — Custom blacklist rules, Safe Mode, and cache management.
- ❓ **[Frequently Asked Questions (FAQ)](docs/wiki/FAQ.md)** — Troubleshooting, updater, audio playback, and common solutions.

---

## ✨ Key Features

- **📱 Pinterest-Style Masonry Feed**: Staggered grid layout with instant mode switching (Masonry, 1:1 Square Grid, Compact List).
- **💾 Offline 2.0 & Sync Hub**: Browse saved media directly from local storage with zero network requests, storage analytics, and batch export.
- **🔍 Search 2.0**: Instant tag autocomplete, multi-tag queries with `and`, and modifiers such as `type:video` or `rating:safe`.
- **🛡️ Advanced Blacklist / Whitelist**: Filter undesirable content by tags, categories, age ratings, or minimum score thresholds.
- **📁 Smart Download Manager**: Flexible directory and filename templates (`{Artist}`, `{Provider}`, `{Service}`, `{ID}`, `{Date}`).
- **🌑 AMOLED Pure Black**: True deep black background optimized for OLED/AMOLED display power efficiency.

---

## 🌐 Supported Providers

| Provider | API Type | Supported Content |
|---|---|---|
| **Pawchive** | REST API v1 | Patreon, Pixiv Fanbox, Fantia, Boosty, Gumroad, DLsite, Discord |
| **Gelbooru** | JSON / XML API | Anime artworks, tag taxonomy, creator profiles, ratings |
| **Rule34** | Booru API | Expansive booru database, animated WebM/MP4 and GIF |
| **Realbooru** | Scraper / API | Cosplay photography and realistic media |
| **e621 / e926** | REST JSON API | Furry and anthropomorphic art with granular tag search |

---

## 📥 Downloads & Releases

Pre-compiled production releases are available on the **[GitHub Releases](https://github.com/RarDog/Prisma/releases)** page.

| Platform | Architecture | Format | Notes |
|---|---|---|---|
| **Android** | `arm64-v8a` | `.apk` | Recommended for all modern 64-bit Android smartphones |
| **Android** | `armeabi-v7a` | `.apk` | Legacy 32-bit Android devices |
| **Android** | `x86_64` | `.apk` | Android emulators, Chromebooks & x86 tablets |
| **Linux** | `x86_64` | `.tar.gz` | Portable standalone package for Linux distributions |
| **Windows** | `x64` | `.zip` | Portable release for Windows 10 & 11 |
| **macOS** | `Universal` | `.zip` | Portable build for macOS |

---

## 🛠️ Building from Source

### Prerequisites
- **Flutter SDK**: `>= 3.22.0` (Dart `>= 3.4.0`)
- **Android SDK**: Build-Tools & Platform-Tools (for Android targets)
- **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`
- **Windows**: Visual Studio 2022 with "Desktop development with C++"
- **macOS**: Xcode 15+

### Quick Start

```bash
# Clone repository
git clone https://github.com/RarDog/Prisma.git
cd Prisma

# Fetch dependencies
flutter pub get

# Run static analysis and tests
flutter analyze
flutter test

# Launch in debug mode
flutter run
```

### Building Release Packages

```bash
# Android (Split APKs by ABI)
flutter build apk --release --split-per-abi

# Linux (Desktop bundle)
flutter build linux --release

# Windows (Desktop bundle)
flutter build windows --release

# macOS (Desktop bundle)
flutter build macos --release
```

---

## 🏛️ Project Architecture

```text
lib/
 ├── app/               # Routing (GoRouter), theme configuration, l10n (EN/RU), animations
 ├── backend/
 │    ├── di/           # Riverpod dependency injection & providers
 │    ├── models/       # Post, ArtistProfile, PawchiveAccount, AppSettings
 │    ├── providers/    # API integrations (Gelbooru, Rule34, Pawchive, e621)
 │    ├── repositories/ # Local Isar database storage & cache layer
 │    └── services/     # Core services: PawchiveSync, Feed, Search, Downloads, Updates
 ├── core/              # Network client (Dio), database engine, utilities
 ├── features/          # Feature screens: feed, post, artists, favorites, settings
 └── shared/widgets/    # Reusable UI components (PostCard, MasonryGrid, Dock)
```

---

## 🔒 Privacy & Security

- **100% On-Device Storage**: Your browsing history, bookmarks, favorite creators, and credentials stay strictly on your device.
- **Zero Telemetry**: No background tracking, no third-party analytic SDKs, and no user profiling.
- **Direct Network Requests**: Communication occurs directly between your client and selected provider endpoints without intermediary proxies.

---

## 👥 Authors & Credits

<p align="center">
  <strong>Authors:</strong> <a href="https://github.com/RarDog">RarDog</a> & <a href="https://deepmind.google/technologies/gemini/">Antigravity (Gemini)</a>
</p>

<p align="center">
  <a href="https://github.com/RarDog"><img src="https://img.shields.io/badge/Developer-RarDog-blue?style=for-the-badge&logo=github&logoColor=white" alt="RarDog" /></a>
  <a href="https://deepmind.google/technologies/gemini/"><img src="https://img.shields.io/badge/AI%20Pair-Antigravity%20(Gemini)-8A2BE2?style=for-the-badge&logo=google&logoColor=white" alt="Antigravity" /></a>
</p>

---

## ⚠️ Disclaimer & Vibe Coding

> [!NOTE]
> This project is 100% **vibe coding** built in tandem with an AI coding partner. I have zero background in Dart and Flutter — this project is built for personal use out of pure enthusiasm.
>
> Although every build is personally and thoroughly tested in daily use before being published, the codebase may still contain quirks, bugs, or sub-optimal patterns. This is a passion project built for personal fun and convenience, which means development could slow down or be abandoned at any moment without prior notice. Community contributions, advice, and pull requests are always welcome!

