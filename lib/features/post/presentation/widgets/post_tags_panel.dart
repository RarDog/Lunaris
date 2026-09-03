import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app.dart';
import '../../../../backend/backend.dart';
import '../../../../shared/widgets/tag_chip.dart';
import '../../../feed/presentation/feed_controller.dart';
import '../../../settings/presentation/settings_controller.dart';

class PostTagsPanel extends ConsumerStatefulWidget {
  const PostTagsPanel({required this.post, super.key});

  final Post post;

  @override
  ConsumerState<PostTagsPanel> createState() => _PostTagsPanelState();
}

class _PostTagsPanelState extends ConsumerState<PostTagsPanel> {
  final _expandedGroups = <String>{};

  @override
  Widget build(BuildContext context) {
    final groups = _groups(widget.post);
    if (groups.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries)
          _TagGroupBlock(
            label: _label(entry.key),
            group: entry.key,
            tags: entry.value,
            expanded: _expandedGroups.contains(entry.key),
            onToggleExpanded: () {
              setState(() {
                if (!_expandedGroups.add(entry.key)) {
                  _expandedGroups.remove(entry.key);
                }
              });
            },
            onTap: (tag) => context.go('/?q=${Uri.encodeQueryComponent(tag)}'),
            onLongPress: (tag) =>
                _showTagActionSheet(context, tag: tag, group: entry.key),
          ),
      ],
    );
  }

  void _showTagActionSheet(
    BuildContext context, {
    required String tag,
    required String group,
  }) {
    final currentTags =
        ref.read(feedControllerProvider).value?.selectedTags ?? const [];
    final settings =
        ref.read(appSettingsProvider).value ?? AppSettings.defaults;
    final isBlacklisted = settings.blacklistedTags.contains(tag);
    final isArtist = group == 'artist';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _label(group),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tag,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.search_rounded),
                    title: const Text('Искать только этот тег'),
                    onTap: () {
                      Navigator.pop(modalContext);
                      context.go('/?q=${Uri.encodeQueryComponent(tag)}');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline_rounded),
                    title: const Text('Добавить к поиску (+тег)'),
                    subtitle: currentTags.isNotEmpty
                        ? Text('Текущие: ${currentTags.join(', ')}')
                        : null,
                    onTap: () {
                      Navigator.pop(modalContext);
                      final nextQuery = currentTags.contains(tag)
                          ? currentTags.join(' ')
                          : [...currentTags, tag].join(' ');
                      context.go('/?q=${Uri.encodeQueryComponent(nextQuery)}');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.remove_circle_outline_rounded),
                    title: const Text('Исключить из поиска (-тег)'),
                    onTap: () {
                      Navigator.pop(modalContext);
                      final filtered = currentTags
                          .where((t) => t != tag && t != '-$tag')
                          .toList();
                      final nextQuery = [...filtered, '-$tag'].join(' ');
                      context.go('/?q=${Uri.encodeQueryComponent(nextQuery)}');
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      isBlacklisted
                          ? Icons.block_flipped
                          : Icons.block_rounded,
                      color: isBlacklisted
                          ? null
                          : Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      isBlacklisted
                          ? 'Удалить из чёрного списка'
                          : 'В чёрный список (Blacklist)',
                    ),
                    onTap: () async {
                      Navigator.pop(modalContext);
                      final updatedList = isBlacklisted
                          ? settings.blacklistedTags
                              .where((t) => t != tag)
                              .toList()
                          : [...settings.blacklistedTags, tag];
                      final nextSettings =
                          settings.copyWith(blacklistedTags: updatedList);
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .saveSettings(nextSettings);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBlacklisted
                                  ? 'Тег "$tag" удалён из чёрного списка'
                                  : 'Тег "$tag" добавлен в чёрный список',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded),
                    title: const Text('Скопировать тег'),
                    onTap: () {
                      Navigator.pop(modalContext);
                      Clipboard.setData(ClipboardData(text: tag));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Тег "$tag" скопирован в буфер'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  if (isArtist)
                    ListTile(
                      leading: const Icon(Icons.palette_rounded),
                      title: const Text('Все работы этого автора'),
                      onTap: () {
                        Navigator.pop(modalContext);
                        context.go('/?q=${Uri.encodeQueryComponent(tag)}');
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, List<String>> _groups(Post post) {
    if (post.tagGroups.isNotEmpty) {
      final ordered = <String, List<String>>{};
      for (final key in [
        'artist',
        'character',
        'copyright',
        'species',
        'meta',
        'general',
      ]) {
        final tags = post.tagGroups[key];
        if (tags != null && tags.isNotEmpty) ordered[key] = tags;
      }
      for (final entry in post.tagGroups.entries) {
        if (entry.value.isNotEmpty) {
          ordered.putIfAbsent(entry.key, () => entry.value);
        }
      }
      return ordered;
    }
    return post.tags.isEmpty ? const {} : {'general': post.tags};
  }

  String _label(String key) {
    return switch (key) {
      'artist' => 'Artist',
      'character' => 'Character',
      'copyright' => 'Copyright / Title',
      'species' => 'Species',
      'meta' => 'Meta',
      'general' => 'General',
      _ => 'Other',
    };
  }
}

class _TagGroupBlock extends StatelessWidget {
  const _TagGroupBlock({
    required this.label,
    required this.group,
    required this.tags,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onTap,
    required this.onLongPress,
  });

  static const _collapsedLimit = 36;

  final String label;
  final String group;
  final List<String> tags;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onLongPress;

  @override
  Widget build(BuildContext context) {
    final visibleTags = expanded || tags.length <= _collapsedLimit
        ? tags
        : tags.take(_collapsedLimit).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: 8),
              Text(
                '${tags.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in visibleTags)
                TagChip(
                  tag: tag,
                  onTap: () => onTap(tag),
                  onLongPress: () => onLongPress(tag),
                ),
              if (tags.length > _collapsedLimit)
                ActionChip(
                  avatar: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                  ),
                  label: Text(
                    expanded ? 'Collapse' : '+${tags.length - _collapsedLimit}',
                  ),
                  onPressed: onToggleExpanded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
