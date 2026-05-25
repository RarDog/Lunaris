import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/motion.dart';
import '../../app/responsive.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const destinations = [
    _Destination('Feed', Icons.dashboard_rounded, '/'),
    _Destination('Search', Icons.search_rounded, '/search'),
    _Destination('Favorites', Icons.favorite_rounded, '/favorites'),
    _Destination('Viewed', Icons.history_rounded, '/viewed'),
    _Destination(
        'Collections', Icons.collections_bookmark_rounded, '/collections'),
    _Destination('Providers', Icons.hub_rounded, '/providers'),
    _Destination('Settings', Icons.settings_rounded, '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
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
            const _NavigateIntent('/providers'),
        LogicalKeySet(LogicalKeyboardKey.digit7):
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
              ? _DesktopShell(child: child)
              : _MobileShell(child: child),
        ),
      ),
    );
  }
}

class _DesktopShell extends StatefulWidget {
  const _DesktopShell({required this.child});
  final Widget child;

  @override
  State<_DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<_DesktopShell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = AppShell.destinations.indexWhere(
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
                          index < AppShell.destinations.length;
                          index++)
                        _RailButton(
                          destination: AppShell.destinations[index],
                          selected: (selected < 0 ? 0 : selected) == index,
                          expanded: _hovered,
                          onTap: () {
                            context.go(AppShell.destinations[index].location);
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
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: expanded ? '' : destination.label,
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
                              destination.label,
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
  const _MobileShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final items = AppShell.destinations.take(5).toList();
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
              tooltip: 'Settings',
              onPressed: () => context.go('/settings'),
              child: const Icon(Icons.settings_rounded),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        onDestinationSelected: (index) => context.go(items[index].location),
        destinations: [
          for (final item in items)
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.location);
  final String label;
  final IconData icon;
  final String location;
}

class _NavigateIntent extends Intent {
  const _NavigateIntent(this.location);
  final String location;
}

class _BackIntent extends Intent {
  const _BackIntent();
}
