import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/motion.dart';
import '../../app/responsive.dart';
import '../../backend/backend.dart';
import '../../core/utils/result.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final artistConfigs =
        ref.watch(_enabledArtistConfigsProvider).value ?? const [];
    final destinations =
        _visibleDestinations(settings, artistConfigs.isNotEmpty);
    final ru = settings.languageCode == 'ru';
    return Shortcuts(
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
              context.go(intent.location);
              return null;
            },
          ),
          _BackIntent: CallbackAction<_BackIntent>(
            onInvoke: (_) {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
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
                  child: child,
                )
              : _MobileShell(
                  destinations: destinations,
                  ru: ru,
                  child: child,
                ),
        ),
      ),
    );
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
}

class _DesktopShell extends StatefulWidget {
  const _DesktopShell({
    required this.child,
    required this.destinations,
    required this.ru,
  });
  final Widget child;
  final List<_Destination> destinations;
  final bool ru;

  @override
  State<_DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<_DesktopShell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = widget.destinations.indexWhere(
      (item) => item.location == '/'
          ? location == '/'
          : location.startsWith(item.location),
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
                            context.go(widget.destinations[index].location);
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
  });
  final Widget child;
  final List<_Destination> destinations;
  final bool ru;

  @override
  Widget build(BuildContext context) {
    final items = destinations
        .where((item) =>
            item.location != '/providers' && item.location != '/settings')
        .take(6)
        .toList();
    final location = GoRouterState.of(context).uri.path;
    final selected = items.indexWhere(
      (item) => item.location == '/'
          ? location == '/'
          : location.startsWith(item.location),
    );
    return Scaffold(
      body: child,
      floatingActionButton: location == '/settings'
          ? null
          : FloatingActionButton.small(
              heroTag: 'mobile-settings',
              tooltip: ru ? 'Настройки' : 'Settings',
              onPressed: () => context.go('/settings'),
              child: const Icon(Icons.settings_rounded),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        onDestinationSelected: (index) => context.go(items[index].location),
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              label: item.mobileLabelFor(ru),
            ),
        ],
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
      'feed' => 'Лента',
      'search' => 'Поиск',
      'favorites' => 'Избранное',
      'viewed' => 'История',
      'collections' => 'Коллекции',
      'artists' => 'Авторы',
      'providers' => 'Провайдеры',
      'settings' => 'Настройки',
      _ => label,
    };
  }

  String mobileLabelFor(bool ru) {
    if (!ru) return mobileLabel;
    return switch (id) {
      'collections' => 'Колл.',
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
