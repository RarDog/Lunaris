import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/responsive.dart';
import '../../app/router.dart';
import '../../backend/backend.dart';
import '../../core/utils/result.dart';
import '../../features/feed/presentation/feed_controller.dart';
import 'desktop_shortcuts_dialog.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    required this.child,
    this.navigationShell,
    super.key,
  });

  final Widget child;
  final StatefulNavigationShell? navigationShell;

  static const destinations = [
    _Destination('feed', 'Feed', Icons.dashboard_rounded, '/'),
    _Destination('search', 'Search', Icons.search_rounded, '/search'),
    _Destination(
        'favorites', 'Favorites', Icons.favorite_rounded, '/favorites'),
    _Destination('viewed', 'Viewed', Icons.history_rounded, '/viewed'),
    _Destination(
      'collections',
      'Collections',
      Icons.collections_bookmark_rounded,
      '/collections',
      mobileLabel: 'Boards',
    ),
    _Destination('artists', 'Artists', Icons.person_search_rounded, '/artists'),
    _Destination('providers', 'Providers', Icons.hub_rounded, '/providers'),
    _Destination('settings', 'Settings', Icons.settings_rounded, '/settings'),
  ];

  static int branchIndexForLocation(String location) {
    if (location.startsWith('/settings')) return 7;
    if (location.startsWith('/providers')) return 6;
    if (location.startsWith('/artists')) return 5;
    if (location.startsWith('/collections')) return 4;
    if (location.startsWith('/viewed')) return 3;
    if (location.startsWith('/favorites')) return 2;
    if (location.startsWith('/search')) return 1;
    return 0;
  }

  static String locationForBranchIndex(int index) {
    return switch (index) {
      1 => '/search',
      2 => '/favorites',
      3 => '/viewed',
      4 => '/collections',
      5 => '/artists',
      6 => '/providers',
      7 => '/settings',
      _ => '/',
    };
  }

  static List<_Destination> _visibleDestinations(
    AppSettings settings,
    bool hasArtists,
  ) {
    return destinations.where((item) {
      if (settings.hiddenTabs.contains(item.id)) return false;
      if (item.id == 'artists' && !hasArtists) return false;
      return true;
    }).toList(growable: false);
  }

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final List<String> _tabHistory = [];
  String? _currentPath;
  bool _isBackNavigating = false;
  bool _restoredTab = false;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive ||
            state == AppLifecycleState.detached) {
          _saveCurrentLocation();
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(appSettingsProvider).value;
      _maybeRestoreLastActiveTab(settings);
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _saveCurrentLocation([String? location]) {
    final loc = location ??
        _currentPath ??
        (widget.navigationShell != null
            ? AppShell.locationForBranchIndex(
                widget.navigationShell!.currentIndex)
            : '/');
    ref.read(settingsServiceProvider).saveLastActiveLocation(loc);
  }

  void _maybeRestoreLastActiveTab(AppSettings? settings) {
    if (_restoredTab || settings == null) return;
    final lastLocation = settings.lastActiveLocation;
    if (lastLocation.isNotEmpty && lastLocation != '/') {
      final idx = AppShell.branchIndexForLocation(lastLocation);
      if (idx > 0 && widget.navigationShell != null) {
        _restoredTab = true;
        widget.navigationShell!.goBranch(idx, initialLocation: false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).uri.path;
    _syncPath(path);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final path = GoRouterState.of(context).uri.path;
    _syncPath(path);
  }

  void _syncPath(String path) {
    if (_isBackNavigating) {
      _isBackNavigating = false;
      _currentPath = path;
      return;
    }
    if (_currentPath != null && _currentPath != path) {
      if (path == '/') {
        _tabHistory.clear();
      } else {
        _tabHistory.remove(_currentPath);
        _tabHistory.add(_currentPath!);
        if (_tabHistory.length > 25) {
          _tabHistory.removeAt(0);
        }
      }
    }
    _currentPath = path;
    _saveCurrentLocation(path);
  }

  void _onNavigate(String location) {
    final targetIndex = AppShell.branchIndexForLocation(location);
    if (widget.navigationShell != null) {
      if (widget.navigationShell!.currentIndex == targetIndex) {
        branchNavKeys[targetIndex]
            .currentState
            ?.popUntil((route) => route.isFirst);
      } else {
        widget.navigationShell!.goBranch(
          targetIndex,
          initialLocation: false,
        );
      }
    } else {
      context.go(location);
    }
    _saveCurrentLocation(location);
  }

  bool _handleBack() {
    final shell = widget.navigationShell;
    if (shell != null) {
      final currentBranchKey = branchNavKeys[shell.currentIndex];
      if (currentBranchKey.currentState?.canPop() ?? false) {
        currentBranchKey.currentState?.pop();
        return true;
      }
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return true;
    }

    final currentPath = GoRouterState.of(context).uri.path;
    while (_tabHistory.isNotEmpty && _tabHistory.last == currentPath) {
      _tabHistory.removeLast();
    }

    if (_tabHistory.isNotEmpty) {
      final previous = _tabHistory.removeLast();
      _isBackNavigating = true;
      _onNavigate(previous);
      return true;
    }

    if (currentPath != '/' && (shell == null || shell.currentIndex != 0)) {
      _isBackNavigating = true;
      _onNavigate('/');
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AppSettings>>(appSettingsProvider, (prev, next) {
      next.whenData((settings) {
        _maybeRestoreLastActiveTab(settings);
      });
    });

    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final artistConfigs =
        ref.watch(_enabledArtistConfigsProvider).value ?? const [];
    final destinations =
        AppShell._visibleDestinations(settings, artistConfigs.isNotEmpty);
    final ru = settings.languageCode == 'ru';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final handled = _handleBack();
        if (!handled) {
          SystemNavigator.pop();
        }
      },
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
              const _NavigateIntent('/search'),
          LogicalKeySet(LogicalKeyboardKey.escape): const _BackIntent(),
          // Ctrl + 1..8
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
              const _NavigateIntent('/'),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
              const _NavigateIntent('/search'),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
              const _NavigateIntent('/favorites'),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit4):
              const _NavigateIntent('/viewed'),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit5):
              const _NavigateIntent('/collections'),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit6):
              const _NavigateIntent('/artists'),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit7):
              const _NavigateIntent('/providers'),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit8):
              const _NavigateIntent('/settings'),
          // Alt + 1..8
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit1):
              const _NavigateIntent('/'),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit2):
              const _NavigateIntent('/search'),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit3):
              const _NavigateIntent('/favorites'),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit4):
              const _NavigateIntent('/viewed'),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit5):
              const _NavigateIntent('/collections'),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit6):
              const _NavigateIntent('/artists'),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit7):
              const _NavigateIntent('/providers'),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.digit8):
              const _NavigateIntent('/settings'),
          // Tab cycling
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.tab):
              const _CycleTabIntent(forward: true),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
              const _CycleTabIntent(forward: false),
          // Refresh
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
              const _RefreshIntent(),
          LogicalKeySet(LogicalKeyboardKey.f5): const _RefreshIntent(),
          // Shortcuts help cheat sheet
          LogicalKeySet(LogicalKeyboardKey.question): const _HelpIntent(),
          LogicalKeySet(LogicalKeyboardKey.f1): const _HelpIntent(),
          LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.slash):
              const _HelpIntent(),
        },
        child: Actions(
          actions: {
            _NavigateIntent: CallbackAction<_NavigateIntent>(
              onInvoke: (intent) {
                _onNavigate(intent.location);
                return null;
              },
            ),
            _BackIntent: CallbackAction<_BackIntent>(
              onInvoke: (_) {
                _handleBack();
                return null;
              },
            ),
            _CycleTabIntent: CallbackAction<_CycleTabIntent>(
              onInvoke: (intent) {
                if (destinations.isEmpty) return null;
                final currentBranch = widget.navigationShell?.currentIndex ?? 0;
                final currentIdx = destinations.indexWhere(
                  (d) => AppShell.branchIndexForLocation(d.location) == currentBranch,
                );
                final safeIdx = currentIdx < 0 ? 0 : currentIdx;
                final nextIdx = intent.forward
                    ? ((safeIdx + 1) % destinations.length)
                    : ((safeIdx - 1 + destinations.length) % destinations.length);
                _onNavigate(destinations[nextIdx].location);
                return null;
              },
            ),
            _RefreshIntent: CallbackAction<_RefreshIntent>(
              onInvoke: (_) {
                ref.read(feedControllerProvider.notifier).refresh();
                return null;
              },
            ),
            _HelpIntent: CallbackAction<_HelpIntent>(
              onInvoke: (_) {
                DesktopShortcutsDialog.show(context);
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: Responsive.isDesktop(context)
                ? _DesktopShell(
                    destinations: destinations,
                    ru: ru,
                    currentBranchIndex: widget.navigationShell?.currentIndex,
                    onNavigate: _onNavigate,
                    child: widget.child,
                  )
                : _MobileShell(
                    destinations: destinations,
                    ru: ru,
                    currentBranchIndex: widget.navigationShell?.currentIndex,
                    onNavigate: _onNavigate,
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }
}

class _DesktopShell extends StatefulWidget {
  const _DesktopShell({
    required this.child,
    required this.destinations,
    required this.ru,
    required this.onNavigate,
    this.currentBranchIndex,
  });

  final Widget child;
  final List<_Destination> destinations;
  final bool ru;
  final ValueChanged<String> onNavigate;
  final int? currentBranchIndex;

  @override
  State<_DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<_DesktopShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _hovered = false;
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool hovered) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
    if (_pinned) return;
    if (hovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _togglePinned() {
    setState(() {
      _pinned = !_pinned;
      if (_pinned) {
        _controller.forward();
      } else if (!_hovered) {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.path;
    final activeBranch = widget.currentBranchIndex ??
        AppShell.branchIndexForLocation(location);
    final selected = widget.destinations.indexWhere(
      (item) => AppShell.branchIndexForLocation(item.location) == activeBranch,
    );

    return Scaffold(
      body: Row(
        children: [
          MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final progress = _animation.value;
                final width = lerpDouble(74.0, 260.0, progress)!;
                final contentOpacity =
                    (progress - 0.25).clamp(0.0, 0.75) / 0.75;
                final isFullyExpanded = progress > 0.85;

                return Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: isDark
                        ? scheme.surfaceContainerHigh
                        : scheme.surface,
                    border: Border(
                      right: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : scheme.outlineVariant.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(3, 0),
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      minWidth: 260,
                      maxWidth: 260,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 260,
                        child: SafeArea(
                          child: Column(
                            children: [
                              // App Brand Header
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 16, 12, 14),
                                child: SizedBox(
                                  height: 44,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              scheme.primary,
                                              scheme.tertiary,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: scheme.primary
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 12,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.auto_awesome_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Opacity(
                                          opacity: contentOpacity,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Lunaris',
                                                      maxLines: 1,
                                                      softWrap: false,
                                                      style: theme
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 1.5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: scheme.primary
                                                            .withValues(
                                                                alpha: 0.15),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        border: Border.all(
                                                          color: scheme.primary
                                                              .withValues(
                                                                  alpha: 0.3),
                                                          width: 0.8,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'v3.6.3',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: scheme.primary,
                                                          letterSpacing: 0.4,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                tooltip: _pinned
                                                    ? (widget.ru
                                                        ? 'Открепить панель'
                                                        : 'Unpin panel')
                                                    : (widget.ru
                                                        ? 'Закрепить панель'
                                                        : 'Pin panel'),
                                                onPressed: _togglePinned,
                                                icon: Icon(
                                                  _pinned
                                                      ? Icons.push_pin_rounded
                                                      : Icons.push_pin_outlined,
                                                  size: 19,
                                                  color: _pinned
                                                      ? scheme.primary
                                                      : scheme
                                                          .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              const SizedBox(height: 8),

                              // Destinations List
                              Expanded(
                                child: ListView(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  children: [
                                    for (var index = 0;
                                        index < widget.destinations.length;
                                        index++)
                                      _RailButton(
                                        destination: widget.destinations[index],
                                        ru: widget.ru,
                                        selected: (selected < 0 ? 0 : selected) ==
                                            index,
                                        contentOpacity: contentOpacity,
                                        isFullyExpanded: isFullyExpanded,
                                        shortcutKey: 'Ctrl+${index + 1}',
                                        onTap: () {
                                          widget.onNavigate(
                                              widget.destinations[index]
                                                  .location);
                                        },
                                      ),
                                  ],
                                ),
                              ),

                              // Bottom Actions
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                child: SizedBox(
                                  width: 244,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Tooltip(
                                          message: isFullyExpanded
                                              ? ''
                                              : (widget.ru
                                                  ? 'Горячие клавиши (F1 / ?)'
                                                  : 'Keyboard Shortcuts (F1 / ?)'),
                                          waitDuration: const Duration(
                                              milliseconds: 350),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            clipBehavior: Clip.antiAlias,
                                            child: InkWell(
                                              onTap: () =>
                                                  DesktopShortcutsDialog.show(
                                                      context),
                                              child: SizedBox(
                                                height: 44,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 58,
                                                      child: Icon(
                                                        Icons.keyboard_rounded,
                                                        size: 22,
                                                        color: scheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Opacity(
                                                        opacity: contentOpacity,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                widget.ru
                                                                    ? 'Горячие клавиши'
                                                                    : 'Shortcuts',
                                                                maxLines: 1,
                                                                softWrap: false,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 13,
                                                                  color: scheme
                                                                      .onSurface,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isDark
                                                                    ? Colors
                                                                        .white
                                                                        .withValues(
                                                                            alpha:
                                                                                0.1)
                                                                    : Colors
                                                                        .black
                                                                        .withValues(
                                                                            alpha:
                                                                                0.06),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                              ),
                                                              child: const Text(
                                                                '?',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'monospace',
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!_pinned && progress < 0.4)
                                        IconButton(
                                          tooltip: widget.ru
                                              ? 'Закрепить панель'
                                              : 'Pin sidebar',
                                          onPressed: _togglePinned,
                                          icon: const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 20),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.destination,
    required this.selected,
    required this.contentOpacity,
    required this.isFullyExpanded,
    required this.ru,
    required this.shortcutKey,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final double contentOpacity;
  final bool isFullyExpanded;
  final bool ru;
  final String shortcutKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final label = destination.labelFor(ru);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Tooltip(
        message: isFullyExpanded ? '' : '$label ($shortcutKey)',
        waitDuration: const Duration(milliseconds: 350),
        child: Material(
          color: selected
              ? scheme.primary.withValues(alpha: isDark ? 0.22 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 244,
              height: 46,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: selected
                      ? Border.all(
                          color: scheme.primary
                              .withValues(alpha: isDark ? 0.45 : 0.28),
                          width: 1.1,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    // Active left indicator bar
                    Container(
                      width: 3.5,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected ? scheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 54.5,
                      child: Center(
                        child: Icon(
                          destination.icon,
                          size: 22,
                          color: selected
                              ? scheme.primary
                              : (isDark
                                  ? scheme.onSurfaceVariant
                                      .withValues(alpha: 0.85)
                                  : scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Opacity(
                        opacity: contentOpacity,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? scheme.primary
                                      : scheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.08),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                shortcutKey,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: selected
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant
                                          .withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.child,
    required this.destinations,
    required this.ru,
    required this.onNavigate,
    this.currentBranchIndex,
  });
  final Widget child;
  final List<_Destination> destinations;
  final bool ru;
  final ValueChanged<String> onNavigate;
  final int? currentBranchIndex;

  @override
  Widget build(BuildContext context) {
    final items = destinations
        .where((item) =>
            item.location != '/providers' && item.location != '/settings')
        .take(6)
        .toList();
    final location = GoRouterState.of(context).uri.path;
    final activeBranch = currentBranchIndex ??
        AppShell.branchIndexForLocation(location);
    final selected = items.indexWhere(
      (item) => AppShell.branchIndexForLocation(item.location) == activeBranch,
    );
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomInset = isKeyboardOpen
        ? 0.0
        : 76.0 + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          viewInsets: MediaQuery.of(context).viewInsets.copyWith(bottom: 0),
          padding: MediaQuery.of(context).padding.copyWith(
                bottom: bottomInset,
              ),
        ),
        child: child,
      ),
      floatingActionButton: (activeBranch == 7 || isKeyboardOpen)
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 0, right: 2),
              child: _LiquidGlassSettingsButton(
                ru: ru,
                onTap: () => onNavigate('/settings'),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: isKeyboardOpen
          ? null
          : _LiquidGlassBottomBar(
              selectedIndex: selected < 0 ? 0 : selected,
              onDestinationSelected: (index) =>
                  onNavigate(items[index].location),
              items: items,
              ru: ru,
            ),
    );
  }
}

class _LiquidGlassBottomBar extends StatefulWidget {
  const _LiquidGlassBottomBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
    required this.ru,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_Destination> items;
  final bool ru;

  @override
  State<_LiquidGlassBottomBar> createState() => _LiquidGlassBottomBarState();
}

class _LiquidGlassBottomBarState extends State<_LiquidGlassBottomBar> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final count = widget.items.length;
    if (count == 0) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final itemWidth = barWidth / count;
            final pillWidth = (itemWidth - 6).clamp(36.0, 64.0);
            final pillLeft =
                widget.selectedIndex * itemWidth + (itemWidth - pillWidth) / 2;

            return Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.09),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                  if (isDark)
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.07),
                      blurRadius: 18,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                scheme.surfaceContainerHigh
                                    .withValues(alpha: 0.70),
                                scheme.surface.withValues(alpha: 0.82),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.84),
                                Colors.white.withValues(alpha: 0.68),
                              ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.75),
                        width: 1.2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Animated sliding liquid pill indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          left: pillLeft,
                          top: 7,
                          child: Container(
                            width: pillWidth,
                            height: 32,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(
                                alpha: isDark ? 0.75 : 0.88,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: scheme.primary.withValues(
                                  alpha: isDark ? 0.35 : 0.22,
                                ),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(
                                    alpha: isDark ? 0.22 : 0.12,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Navigation item buttons
                        Row(
                          children: [
                            for (var i = 0; i < count; i++)
                              Expanded(
                                child: _LiquidNavItem(
                                  destination: widget.items[i],
                                  label: widget.items[i]
                                      .mobileLabelFor(widget.ru),
                                  isSelected: widget.selectedIndex == i,
                                  isPressed: _pressedIndex == i,
                                  onTapDown: () =>
                                      setState(() => _pressedIndex = i),
                                  onTapUp: () =>
                                      setState(() => _pressedIndex = null),
                                  onTapCancel: () =>
                                      setState(() => _pressedIndex = null),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    widget.onDestinationSelected(i);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LiquidNavItem extends StatelessWidget {
  const _LiquidNavItem({
    required this.destination,
    required this.label,
    required this.isSelected,
    required this.isPressed,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.onTap,
  });

  final _Destination destination;
  final String label;
  final bool isSelected;
  final bool isPressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final targetScale = isPressed ? 0.86 : (isSelected ? 1.05 : 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapCancel,
      onTap: onTap,
      child: Center(
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 32,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: child,
                    ),
                    child: Icon(
                      destination.icon,
                      key: ValueKey('${destination.id}_$isSelected'),
                      size: isSelected ? 22 : 20,
                      color: isSelected
                          ? scheme.onPrimaryContainer
                          : (isDark
                              ? scheme.onSurfaceVariant
                                  .withValues(alpha: 0.78)
                              : scheme.onSurfaceVariant
                                  .withValues(alpha: 0.85)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? scheme.primary : scheme.onSurface)
                      : scheme.onSurfaceVariant.withValues(alpha: 0.75),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassSettingsButton extends StatefulWidget {
  const _LiquidGlassSettingsButton({
    required this.ru,
    required this.onTap,
  });

  final bool ru;
  final VoidCallback onTap;

  @override
  State<_LiquidGlassSettingsButton> createState() =>
      _LiquidGlassSettingsButtonState();
}

class _LiquidGlassSettingsButtonState extends State<_LiquidGlassSettingsButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return Tooltip(
      message: widget.ru ? 'Настройки' : 'Settings',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  spreadRadius: -1,
                ),
                BoxShadow(
                  color: scheme.primary.withValues(alpha: isDark ? 0.20 : 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.4),
                      radius: 1.1,
                      colors: isDark
                          ? [
                              scheme.surfaceContainerHigh.withValues(alpha: 0.85),
                              scheme.surface.withValues(alpha: 0.75),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.92),
                              Colors.white.withValues(alpha: 0.70),
                            ],
                    ),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.24)
                          : Colors.white.withValues(alpha: 0.85),
                      width: 1.4,
                    ),
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _pressed ? 0.125 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        Icons.settings_rounded,
                        size: 23,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(
    this.id,
    this.label,
    this.icon,
    this.location, {
    String? mobileLabel,
  }) : mobileLabel = mobileLabel ?? label;

  final String id;
  final String label;
  final String mobileLabel;
  final IconData icon;
  final String location;

  String labelFor(bool ru) {
    if (!ru) return label;
    return switch (id) {
      'feed' => '\u041b\u0435\u043d\u0442\u0430',
      'search' => '\u041f\u043e\u0438\u0441\u043a',
      'favorites' => '\u0418\u0437\u0431\u0440\u0430\u043d\u043d\u043e\u0435',
      'viewed' => '\u0418\u0441\u0442\u043e\u0440\u0438\u044f',
      'collections' => '\u041a\u043e\u043b\u043b\u0435\u043a\u0446\u0438\u0438',
      'artists' => '\u0410\u0440\u0442\u0438\u0441\u0442\u044b',
      'providers' =>
        '\u041f\u0440\u043e\u0432\u0430\u0439\u0434\u0435\u0440\u044b',
      'settings' => '\u041d\u0430\u0441\u0442\u0440\u043e\u0439\u043a\u0438',
      _ => label,
    };
  }

  String mobileLabelFor(bool ru) {
    if (!ru) return mobileLabel;
    return switch (id) {
      'collections' => '\u0414\u043e\u0441\u043a\u0438',
      'favorites' => '\u041b\u044e\u0431\u0438\u043c\u043e\u0435',
      _ => labelFor(true),
    };
  }
}

final _enabledArtistConfigsProvider =
    FutureProvider<List<ContentProviderConfig>>((ref) async {
  ref.watch(appSettingsProvider);
  final result = await ref
      .watch(providerManagerProvider)
      .loadArtistConfigs(enabledOnly: true);
  return result is Success<List<ContentProviderConfig>>
      ? result.data
      : const [];
});

class _NavigateIntent extends Intent {
  const _NavigateIntent(this.location);
  final String location;
}

class _BackIntent extends Intent {
  const _BackIntent();
}

class _CycleTabIntent extends Intent {
  const _CycleTabIntent({required this.forward});
  final bool forward;
}

class _RefreshIntent extends Intent {
  const _RefreshIntent();
}

class _HelpIntent extends Intent {
  const _HelpIntent();
}
