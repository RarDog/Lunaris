import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/app_strings.dart';
import '../../../backend/backend.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_view.dart';
import 'search_controller.dart';
import 'widgets/recent_searches.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  bool _showTips = false;

  void _onTagTap(String tag, String currentQuery) {
    final trimmed = currentQuery.trim();
    if (trimmed.isEmpty) {
      context.go('/?q=${Uri.encodeQueryComponent(tag)}');
    } else {
      final newQuery = '$trimmed $tag';
      ref.read(searchControllerProvider.notifier).updateQuery(newQuery);
      context.go('/?q=${Uri.encodeQueryComponent(newQuery)}');
    }
  }

  void _appendToken(String token, String currentQuery) {
    final trimmed = currentQuery.trim();
    final newQuery = trimmed.isEmpty ? token : '$trimmed $token';
    ref.read(searchControllerProvider.notifier).updateQuery(newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final strings = AppStrings(settings.languageCode);
    final isRu = strings.ru;
    final theme = Theme.of(context);

    return AdaptiveScaffold(
      title: strings.search,
      actions: [
        IconButton(
          tooltip: isRu ? 'Очистить историю' : 'Clear history',
          onPressed: () async {
            final ok = await showConfirmDialog(
              context,
              title: isRu ? 'Очистить историю поиска?' : 'Clear search history?',
              message: isRu
                  ? 'Все недавние поисковые запросы будут удалены.'
                  : 'All recent search queries will be removed.',
            );
            if (ok) {
              await ref
                  .read(searchControllerProvider.notifier)
                  .clearHistory();
            }
          },
          icon: const Icon(Icons.delete_sweep_rounded),
        ),
      ],
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (data) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // 1. Search Bar with Quick Operators
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TagInputSearchBar(
                        initialValue: data.query,
                        suggestions: data.suggestions,
                        onSubmitted: (query) => context
                            .go('/?q=${Uri.encodeQueryComponent(query)}'),
                        onChanged: (query) => ref
                            .read(searchControllerProvider.notifier)
                            .updateQuery(query),
                        onSuggestionApplied: (query) => ref
                            .read(searchControllerProvider.notifier)
                            .updateQuery(query),
                        onTagRemoved: (query) => ref
                            .read(searchControllerProvider.notifier)
                            .updateQuery(query),
                        onCleared: () => ref
                            .read(searchControllerProvider.notifier)
                            .updateQuery(''),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _QuickOperatorChip(
                              label: 'and',
                              icon: Icons.alt_route_rounded,
                              color: const Color(0xFFF59E0B),
                              onTap: () => _appendToken('and', data.query),
                            ),
                            const SizedBox(width: 8),
                            _QuickOperatorChip(
                              label: 'type:video',
                              icon: Icons.videocam_rounded,
                              color: const Color(0xFF3B82F6),
                              onTap: () =>
                                  _appendToken('type:video', data.query),
                            ),
                            const SizedBox(width: 8),
                            _QuickOperatorChip(
                              label: 'type:gif',
                              icon: Icons.gif_rounded,
                              color: const Color(0xFF8B5CF6),
                              onTap: () => _appendToken('type:gif', data.query),
                            ),
                            const SizedBox(width: 8),
                            _QuickOperatorChip(
                              label: 'rating:safe',
                              icon: Icons.verified_user_rounded,
                              color: const Color(0xFF10B981),
                              onTap: () =>
                                  _appendToken('rating:safe', data.query),
                            ),
                            const SizedBox(width: 8),
                            _QuickOperatorChip(
                              label: 'rating:explicit',
                              icon: Icons.explicit_rounded,
                              color: const Color(0xFFEF4444),
                              onTap: () =>
                                  _appendToken('rating:explicit', data.query),
                            ),
                            const SizedBox(width: 8),
                            _QuickOperatorChip(
                              label: 'score:>100',
                              icon: Icons.star_rounded,
                              color: const Color(0xFFF97316),
                              onTap: () =>
                                  _appendToken('score:>100', data.query),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Recent Searches Card
                _SearchSectionCard(
                  icon: Icons.history_rounded,
                  accentColor: const Color(0xFF6366F1),
                  title: isRu ? 'Недавние запросы' : 'Recent searches',
                  badgeCount: data.recent
                      .map((e) => e.query.trim().toLowerCase())
                      .where((q) => q.isNotEmpty)
                      .toSet()
                      .length,
                  trailing: data.recent.isEmpty
                      ? null
                      : TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => ref
                              .read(searchControllerProvider.notifier)
                              .clearHistory(),
                          child: Text(
                            isRu ? 'Очистить' : 'Clear',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  child: RecentSearches(
                    items: data.recent,
                    onTap: (query) =>
                        context.go('/?q=${Uri.encodeQueryComponent(query)}'),
                    onDelete: (id) => ref
                        .read(searchControllerProvider.notifier)
                        .deleteHistory(id),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Explore Popular Categories & Tags
                _SearchSectionCard(
                  icon: Icons.explore_rounded,
                  accentColor: const Color(0xFF10B981),
                  title: isRu ? 'Популярные категории' : 'Explore categories',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryTagRow(
                        categoryName: isRu ? 'Тематика' : 'Theme & Ambience',
                        color: const Color(0xFF0EA5E9),
                        tags: const [
                          'scenery',
                          'cyberpunk',
                          'monochrome',
                          'night',
                          'fantasy',
                          'original',
                        ],
                        onTap: (tag) => _onTagTap(tag, data.query),
                      ),
                      const SizedBox(height: 14),
                      _CategoryTagRow(
                        categoryName:
                            isRu ? 'Персонажи и детали' : 'Characters & Attire',
                        color: const Color(0xFFEC4899),
                        tags: const [
                          '1girl',
                          'solo',
                          'cat_ears',
                          'short_hair',
                          'long_hair',
                          'maid',
                          'uniform',
                        ],
                        onTap: (tag) => _onTagTap(tag, data.query),
                      ),
                      const SizedBox(height: 14),
                      _CategoryTagRow(
                        categoryName: isRu ? 'Провайдеры' : 'Providers',
                        color: const Color(0xFF8B5CF6),
                        tags: const [
                          'provider:gelbooru',
                          'provider:danbooru',
                          'provider:e621',
                          'provider:rule34',
                          'provider:pawchive',
                        ],
                        onTap: (tag) => _onTagTap(tag, data.query),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Search Tips / Cheat Sheet Card
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 18,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    title: Text(
                      isRu ? 'Шпаргалка по поиску' : 'Search tips & operators',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    initiallyExpanded: _showTips,
                    onExpansionChanged: (exp) => setState(() => _showTips = exp),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TipRow(
                              code: 'tag_a and tag_b',
                              description: isRu
                                  ? 'Независимый опрос обоих тегов с чередованием постов в ленте.'
                                  : 'Interleaves results from both queries independently.',
                            ),
                            const SizedBox(height: 8),
                            _TipRow(
                              code: 'type:video / type:gif',
                              description: isRu
                                  ? 'Показывает только видео или анимированные GIF.'
                                  : 'Filters results to only videos or animated GIFs.',
                            ),
                            const SizedBox(height: 8),
                            _TipRow(
                              code: 'rating:safe / rating:explicit',
                              description: isRu
                                  ? 'Фильтр по возрастному рейтингу медиа.'
                                  : 'Filter by age rating classification.',
                            ),
                            const SizedBox(height: 8),
                            _TipRow(
                              code: 'score:>50 / score:>100',
                              description: isRu
                                  ? 'Посты с оценкой пользователей выше указанной.'
                                  : 'Posts with community score greater than threshold.',
                            ),
                            const SizedBox(height: 8),
                            _TipRow(
                              code: 'provider:gelbooru',
                              description: isRu
                                  ? 'Поиск исключительно в указанном источнике.'
                                  : 'Search specifically on the given booru provider.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchSectionCard extends StatelessWidget {
  const _SearchSectionCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.child,
    this.badgeCount,
    this.trailing,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final Widget child;
  final int? badgeCount;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (badgeCount != null && badgeCount! > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _QuickOperatorChip extends StatelessWidget {
  const _QuickOperatorChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTagRow extends StatelessWidget {
  const _CategoryTagRow({
    required this.categoryName,
    required this.color,
    required this.tags,
    required this.onTap,
  });

  final String categoryName;
  final Color color;
  final List<String> tags;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in tags)
              Material(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onTap(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tag,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.code, required this.description});

  final String code;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            code,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
