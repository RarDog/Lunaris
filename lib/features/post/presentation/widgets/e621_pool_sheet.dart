import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../backend/models/e621_pool.dart';
import '../../../../backend/models/post.dart';
import '../../../../backend/providers/e621_provider.dart';

class E621PoolSheet extends StatefulWidget {
  const E621PoolSheet({
    required this.currentPost,
    required this.poolId,
    required this.provider,
    required this.onSelectPostId,
    super.key,
  });

  final Post currentPost;
  final String poolId;
  final E621Provider provider;
  final ValueChanged<String> onSelectPostId;

  static Future<void> show(
    BuildContext context, {
    required Post currentPost,
    required String poolId,
    required E621Provider provider,
    required ValueChanged<String> onSelectPostId,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => E621PoolSheet(
        currentPost: currentPost,
        poolId: poolId,
        provider: provider,
        onSelectPostId: onSelectPostId,
      ),
    );
  }

  @override
  State<E621PoolSheet> createState() => _E621PoolSheetState();
}

class _E621PoolSheetState extends State<E621PoolSheet> {
  E621Pool? _pool;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPool();
  }

  Future<void> _loadPool() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pool = await widget.provider.getPool(widget.poolId);
      if (mounted) {
        setState(() {
          _pool = pool;
          _isLoading = false;
          if (pool == null) {
            _error = 'Не удалось загрузить информацию о серии';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ошибка: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';
    final pool = _pool;

    final currentPage = pool?.pageOf(widget.currentPost.id) ?? 0;
    final prevId = pool?.previousPostId(widget.currentPost.id);
    final nextId = pool?.nextPostId(widget.currentPost.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.88,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161B22).withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.94),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 40, color: Color(0xFFEF4444)),
                            const SizedBox(height: 12),
                            Text(_error!),
                            const SizedBox(height: 12),
                            FilledButton.tonal(
                              onPressed: _loadPool,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (pool != null) ...[
                    // Pool header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0055AA), Color(0xFF0088FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0055AA)
                                    .withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pool.cleanTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0055AA)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF0055AA)
                                            .withValues(alpha: 0.30),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      pool.category == 'series'
                                          ? (isRu ? 'Комикс / Серия' : 'Series')
                                          : (isRu
                                              ? 'Коллекция'
                                              : 'Collection'),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0077EE),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${pool.postCount} ${isRu ? 'страниц' : 'pages'}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (pool.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        pool.description.trim(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Big "Read Full Comic" Button
                    FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                        final startId = pool.postIds.contains(widget.currentPost.id)
                            ? widget.currentPost.id
                            : pool.postIds.first;
                        widget.onSelectPostId(startId);
                      },
                      icon: const Icon(Icons.auto_stories_rounded, size: 18),
                      label: Text(
                        isRu
                            ? 'Читать весь комикс (${pool.postCount} стр.)'
                            : 'Read Full Comic (${pool.postCount} pages)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0055AA),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Page Navigator Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: isRu ? 'Предыдущая' : 'Previous',
                            onPressed: prevId == null
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop();
                                    widget.onSelectPostId(prevId);
                                  },
                            icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  currentPage > 0
                                      ? (isRu
                                          ? 'Страница $currentPage из ${pool.postCount}'
                                          : 'Page $currentPage of ${pool.postCount}')
                                      : (isRu
                                          ? 'Страниц в пуле: ${pool.postCount}'
                                          : '${pool.postCount} pages in pool'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                if (currentPage > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: LinearProgressIndicator(
                                      value: (currentPage / pool.postCount)
                                          .clamp(0.0, 1.0),
                                      borderRadius: BorderRadius.circular(4),
                                      minHeight: 4,
                                      backgroundColor: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.08),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: isRu ? 'Следующая' : 'Next',
                            onPressed: nextId == null
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop();
                                    widget.onSelectPostId(nextId);
                                  },
                            icon: const Icon(Icons.arrow_forward_rounded,
                                size: 18),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      isRu ? 'Все страницы серии:' : 'All pages in pool:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Grid of page buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < pool.postIds.length; i++) ...[
                          _PageButton(
                            pageNumber: i + 1,
                            postId: pool.postIds[i],
                            isCurrent: pool.postIds[i] == widget.currentPost.id,
                            onTap: () {
                              if (pool.postIds[i] == widget.currentPost.id) {
                                return;
                              }
                              HapticFeedback.lightImpact();
                              Navigator.of(context).pop();
                              widget.onSelectPostId(pool.postIds[i]);
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.pageNumber,
    required this.postId,
    required this.isCurrent,
    required this.onTap,
  });

  final int pageNumber;
  final String postId;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minWidth: 42, minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? const Color(0xFF0055AA)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFF0077EE)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08)),
              width: isCurrent ? 1.4 : 0.8,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: const Color(0xFF0055AA).withValues(alpha: 0.40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$pageNumber',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                color: isCurrent
                    ? Colors.white
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
