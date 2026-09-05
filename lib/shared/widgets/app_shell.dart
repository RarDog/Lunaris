import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/motion.dart';
import '../../app/responsive.dart';
import '../../app/router.dart';
import '../../backend/backend.dart';
import '../../core/utils/result.dart';

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
          LogicalKeySet(LogicalKeyboardKey.digit1): const _NavigateIntent('/'),
          LogicalKeySet(LogicalKeyboardKey.digit2):
              const _NavigateIntent('/search'),
          LogicalKeySet(LogicalKeyboardKey.digit3):
              const _NavigateIntent('/favorites'),
          LogicalKeySet(LogicalKeyboardKey.digit4):
              const _NavigateIntent('/viewed'),
          LogicalKeySet(LogicalKeyboardKey.digit5):
              const _NavigateIntent('/collections'),
          LogicalKeySet(LogicalKeyboardKey.digit6):
              const _NavigateIntent('/artists'),
          LogicalKeySet(LogicalKeyboardKey.digit7):
              const _NavigateIntent('/providers'),
          LogicalKeySet(LogicalKeyboardKey.digit8):
              const _NavigateIntent('/settings'),
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

class _DesktopShellState extends State<_DesktopShell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
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
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: AnimatedContainer(
              duration: AppMotion.duration(context, 180),
              curve: Curves.easeOutCubic,
              width: _hovered ? 256 : 72,
              color: Theme.of(context).navigationRailTheme.backgroundColor,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    children: [
                      for (var index = 0;
                          index < widget.destinations.length;
                          index++)
                        _RailButton(
                          destination: widget.destinations[index],
                          ru: widget.ru,
                          selected: (selected < 0 ? 0 : selected) == index,
                          expanded: _hovered,
                          onTap: () {
                            widget.onNavigate(widget.destinations[index].location);
                          },
                        ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
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
    required this.expanded,
    required this.ru,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final bool expanded;
  final bool ru;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: expanded ? '' : destination.labelFor(ru),
        waitDuration: const Duration(milliseconds: 450),
        child: Material(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Icon(
                      destination.icon,
                      color: selected
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  if (expanded)
                    Expanded(
                      child: ClipRect(
                        child: AnimatedOpacity(
                          opacity: 1,
                          duration: AppMotion.duration(context, 120),
                          curve: Curves.easeOut,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              destination.labelFor(ru),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              softWrap: false,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: selected
                                    ? colors.onPrimaryContainer
                                    : colors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (expanded) const SizedBox(width: 12),
                ],
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
