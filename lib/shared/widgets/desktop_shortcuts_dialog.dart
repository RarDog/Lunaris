import 'dart:ui';
import 'package:flutter/material.dart';

class DesktopShortcutsDialog extends StatelessWidget {
  const DesktopShortcutsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const DesktopShortcutsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 680),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? scheme.surfaceContainerHigh.withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : scheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.keyboard_rounded,
                            color: scheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Горячие клавиши',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Быстрое управление с клавиатуры для ПК',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Закрыть (Esc)',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Shortcuts list
                  Flexible(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: const [
                        _ShortcutSection(
                          icon: Icons.navigation_rounded,
                          title: 'Общие и навигация',
                          items: [
                            _ShortcutRow(['Ctrl', '1…8'], 'Переключение между вкладками'),
                            _ShortcutRow(['Ctrl', 'Tab'], 'Следующая вкладка'),
                            _ShortcutRow(['Ctrl', 'Shift', 'Tab'], 'Предыдущая вкладка'),
                            _ShortcutRow(['Ctrl', 'F'], 'Перейти к поиску / строка поиска'),
                            _ShortcutRow(['Ctrl', 'R'], 'Обновить ленту / страницу'),
                            _ShortcutRow(['F5'], 'Обновить страницу'),
                            _ShortcutRow(['Esc'], 'Закрыть окно / назад / сбросить выбор'),
                            _ShortcutRow(['?'], 'Открыть это окно горячих клавиш'),
                          ],
                        ),
                        SizedBox(height: 20),
                        _ShortcutSection(
                          icon: Icons.smart_display_rounded,
                          title: 'Видеоплеер',
                          items: [
                            _ShortcutRow(['Пробел'], 'Воспроизведение / Пауза'),
                            _ShortcutRow(['←', '→'], 'Перемотка на 5 секунд назад / вперед'),
                            _ShortcutRow(['Shift', '← / →'], 'Перемотка на 15 секунд'),
                            _ShortcutRow(['↑', '↓'], 'Регулировка громкости (±5%)'),
                            _ShortcutRow(['M'], 'Включить / выключить звук'),
                            _ShortcutRow(['F'], 'Полноэкранный режим (Full Screen)'),
                            _ShortcutRow(['L'], 'Повтор видео (Loop on/off)'),
                            _ShortcutRow(['Esc'], 'Выйти из полноэкранного режима'),
                          ],
                        ),
                        SizedBox(height: 20),
                        _ShortcutSection(
                          icon: Icons.photo_library_rounded,
                          title: 'Фото и просмотр постов',
                          items: [
                            _ShortcutRow(['←', '→'], 'Предыдущее / следующее фото или пост'),
                            _ShortcutRow(['+'], 'Увеличить масштаб (Zoom In)'),
                            _ShortcutRow(['-'], 'Уменьшить масштаб (Zoom Out)'),
                            _ShortcutRow(['0'], 'Сбросить масштаб (100%)'),
                            _ShortcutRow(['F'], 'Подгонка по экрану / на весь экран'),
                            _ShortcutRow(['D'], 'Скачать текущее изображение'),
                            _ShortcutRow(['Ctrl', 'S'], 'Сохранить / Скачать файл'),
                            _ShortcutRow(['Esc'], 'Сброс зума / назад'),
                          ],
                        ),
                        SizedBox(height: 20),
                        _ShortcutSection(
                          icon: Icons.grid_view_rounded,
                          title: 'Лента и посты',
                          items: [
                            _ShortcutRow(['R'], 'Открыть случайный пост'),
                            _ShortcutRow(['V'], 'Включить/выключить режим выбора постов'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutSection extends StatelessWidget {
  const _ShortcutSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<_ShortcutRow> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? scheme.surface.withValues(alpha: 0.6)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                items[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow(this.keys, this.description);

  final List<String> keys;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: keys.map((key) => _KeyCap(key)).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            offset: const Offset(0, 1.5),
            blurRadius: 1,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
