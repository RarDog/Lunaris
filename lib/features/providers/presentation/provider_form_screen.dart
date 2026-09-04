import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../backend/backend.dart';
import 'providers_controller.dart';

class ProviderFormScreen extends ConsumerStatefulWidget {
  const ProviderFormScreen({this.initialConfig, super.key});

  final ContentProviderConfig? initialConfig;

  @override
  ConsumerState<ProviderFormScreen> createState() => _ProviderFormScreenState();
}

class _ProviderFormScreenState extends ConsumerState<ProviderFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _baseUrl;
  late final TextEditingController _priority;
  late final TextEditingController _timeout;
  late final TextEditingController _headers;
  late final TextEditingController _apiKey;
  late final TextEditingController _userId;
  late final TextEditingController _login;
  late String _apiType;
  late bool _enabled;
  bool _obscureApiKey = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final config = widget.initialConfig;
    _name = TextEditingController(text: config?.name);
    _baseUrl = TextEditingController(text: config?.baseUrl);
    _priority =
        TextEditingController(text: (config?.priority ?? 10).toString());
    _timeout =
        TextEditingController(text: (config?.timeoutSeconds ?? 20).toString());
    _headers = TextEditingController(
      text: jsonEncode(_visibleHeaders(config?.customHeaders ?? const {})),
    );
    _apiKey =
        TextEditingController(text: config?.customHeaders['query.api_key']);
    _userId =
        TextEditingController(text: config?.customHeaders['query.user_id']);
    _login = TextEditingController(text: config?.customHeaders['query.login']);
    _apiType = config?.apiType ?? 'gelbooru';
    _enabled = config?.enabled ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _baseUrl.dispose();
    _priority.dispose();
    _timeout.dispose();
    _headers.dispose();
    _apiKey.dispose();
    _userId.dispose();
    _login.dispose();
    super.dispose();
  }

  void _applyPreset({
    required String name,
    required String baseUrl,
    required String apiType,
  }) {
    HapticFeedback.selectionClick();
    setState(() {
      _name.text = name;
      _baseUrl.text = baseUrl;
      _apiType = apiType;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRu = Localizations.maybeLocaleOf(context)?.languageCode == 'ru';
    final isEdit = widget.initialConfig != null;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AppBar(
              backgroundColor: isDark
                  ? theme.colorScheme.surface.withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.85),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/providers');
                  }
                },
                tooltip: isRu ? 'Назад' : 'Back',
              ),
              title: Text(
                isEdit
                    ? (isRu ? 'Редактирование источника' : 'Edit Provider')
                    : (isRu ? 'Новый источник' : 'New Provider'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 68,
              16,
              140 + bottomInset,
            ),
            children: [
              // Presets bar if creating a new provider
              if (!isEdit) ...[
                Text(
                  isRu ? 'Быстрые пресеты' : 'Quick Presets',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _PresetChip(
                        name: 'Gelbooru',
                        color: const Color(0xFF10B981),
                        onTap: () => _applyPreset(
                          name: 'Gelbooru',
                          baseUrl: 'https://gelbooru.com',
                          apiType: 'gelbooru',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        name: 'Rule34',
                        color: const Color(0xFF84CC16),
                        onTap: () => _applyPreset(
                          name: 'Rule34',
                          baseUrl: 'https://api.rule34.xxx',
                          apiType: 'rule34',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        name: 'Danbooru',
                        color: const Color(0xFF3B82F6),
                        onTap: () => _applyPreset(
                          name: 'Danbooru',
                          baseUrl: 'https://danbooru.donmai.us',
                          apiType: 'danbooru',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        name: 'e621',
                        color: const Color(0xFFF59E0B),
                        onTap: () => _applyPreset(
                          name: 'e621',
                          baseUrl: 'https://e621.net',
                          apiType: 'e621',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        name: 'Yande.re',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => _applyPreset(
                          name: 'Yande.re',
                          baseUrl: 'https://yande.re',
                          apiType: 'moebooru',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        name: 'Konachan',
                        color: const Color(0xFFEC4899),
                        onTap: () => _applyPreset(
                          name: 'Konachan',
                          baseUrl: 'https://konachan.net',
                          apiType: 'moebooru',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        name: 'Paheal',
                        color: const Color(0xFFF97316),
                        onTap: () => _applyPreset(
                          name: 'Rule34 Paheal',
                          baseUrl: 'https://rule34.paheal.net',
                          apiType: 'paheal',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Section 1: General Parameters
              _FormLiquidCard(
                icon: Icons.tune_rounded,
                accentColor: const Color(0xFF6366F1),
                title: isRu ? 'Основные параметры' : 'General Configuration',
                subtitle: isRu
                    ? 'Имя, адрес сервера и тип API движка'
                    : 'Name, server endpoint and API engine',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GlassTextField(
                      controller: _name,
                      label: isRu ? 'Название источника' : 'Provider Name',
                      hint: 'e.g. Gelbooru, Rule34',
                      icon: Icons.label_rounded,
                    ),
                    const SizedBox(height: 14),
                    _GlassTextField(
                      controller: _baseUrl,
                      label: isRu ? 'Базовый URL (Base URL)' : 'Base URL',
                      hint: 'https://example.com',
                      icon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 14),
                    // Dropdown API Type
                    _GlassDropdown(
                      label: isRu ? 'Тип API движка' : 'API Engine Type',
                      value: _apiType,
                      onChanged: (val) {
                        if (val != null) setState(() => _apiType = val);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'gelbooru',
                          child: Text('Gelbooru (compatible)'),
                        ),
                        DropdownMenuItem(
                          value: 'rule34',
                          child: Text('Rule34 (compatible)'),
                        ),
                        DropdownMenuItem(
                          value: 'danbooru',
                          child: Text('Danbooru (compatible)'),
                        ),
                        DropdownMenuItem(
                          value: 'e621',
                          child: Text('e621 / e926'),
                        ),
                        DropdownMenuItem(
                          value: 'moebooru',
                          child: Text('Moebooru (Yande.re, Konachan)'),
                        ),
                        DropdownMenuItem(
                          value: 'paheal',
                          child: Text('Rule34 Paheal HTML'),
                        ),
                        DropdownMenuItem(
                          value: 'realbooru_html',
                          child: Text('Realbooru HTML'),
                        ),
                        DropdownMenuItem(
                          value: 'kemono',
                          child: Text('Kemono Party artists'),
                        ),
                        DropdownMenuItem(
                          value: 'coomer',
                          child: Text('Coomer Party artists'),
                        ),
                        DropdownMenuItem(
                          value: 'custom',
                          child: Text('Custom REST API'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Enabled Switch Tile
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.power_settings_new_rounded,
                            size: 20,
                            color: _enabled
                                ? const Color(0xFF10B981)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isRu ? 'Включить этот источник' : 'Enable provider',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: _enabled,
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              setState(() => _enabled = val);
                            },
                            activeThumbColor: const Color(0xFF10B981),
                            activeTrackColor:
                                const Color(0xFF10B981).withValues(alpha: 0.45),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section 2: Priority & Timeout
              _FormLiquidCard(
                icon: Icons.speed_rounded,
                accentColor: const Color(0xFF10B981),
                title: isRu
                    ? 'Приоритет и производительность'
                    : 'Priority & Performance',
                subtitle: isRu
                    ? 'Порядок выдачи постов и максимальное время ответа'
                    : 'Dispatch priority and maximum network wait time',
                child: Row(
                  children: [
                    Expanded(
                      child: _GlassTextField(
                        controller: _priority,
                        label: isRu ? 'Приоритет (Priority)' : 'Priority',
                        hint: '10',
                        icon: Icons.trending_up_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GlassTextField(
                        controller: _timeout,
                        label: isRu ? 'Таймаут (сек)' : 'Timeout (s)',
                        hint: '20',
                        icon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section 3: Credentials & API Keys
              _FormLiquidCard(
                icon: Icons.vpn_key_rounded,
                accentColor: const Color(0xFFF59E0B),
                title: isRu
                    ? 'Ключи доступа и аккаунт'
                    : 'API Keys & Authentication',
                subtitle: isRu
                    ? 'Необходимы для снятия ограничений на поиск и теги'
                    : 'Required for unrestricted queries and higher limits',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Notice
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B)
                            .withValues(alpha: isDark ? 0.14 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: isDark ? 0.35 : 0.22),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isRu
                                  ? 'Для Gelbooru и Rule34: User ID и API Key можно найти в настройках профиля (Account -> Options).'
                                  : 'For Gelbooru & Rule34: Find your User ID and API Key in Account -> Options.',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _GlassTextField(
                      controller: _apiKey,
                      label: 'API Key',
                      hint: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                      icon: Icons.key_rounded,
                      obscureText: _obscureApiKey,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureApiKey
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _obscureApiKey = !_obscureApiKey),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _GlassTextField(
                      controller: _userId,
                      label: 'User ID',
                      hint: '123456',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _GlassTextField(
                      controller: _login,
                      label: isRu ? 'Логин (Login)' : 'Login Username',
                      hint: 'username',
                      icon: Icons.account_circle_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section 4: Custom Headers JSON
              _FormLiquidCard(
                icon: Icons.terminal_rounded,
                accentColor: const Color(0xFF06B6D4),
                title: isRu ? 'Заголовки JSON' : 'Custom Headers (JSON)',
                subtitle: isRu
                    ? 'Дополнительные HTTP заголовки в формате JSON'
                    : 'Optional custom request headers in JSON map format',
                child: _GlassTextField(
                  controller: _headers,
                  label: isRu ? 'Пользовательские заголовки' : 'Headers JSON',
                  hint: '{"User-Agent": "Lunaris/3.0"}',
                  icon: Icons.code_rounded,
                  minLines: 2,
                  maxLines: 5,
                  isMonospace: true,
                ),
              ),

              const SizedBox(height: 24),

              // Save Action Button
              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _isSaving ? null : _save,
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isRu
                                      ? 'Сохранить провайдер'
                                      : 'Save Provider',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel Button
              Center(
                child: TextButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go('/providers');
                    }
                  },
                  child: Text(
                    isRu ? 'Отмена' : 'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final nameText = _name.text.trim();
    if (nameText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите название провайдера')),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    try {
      final now = DateTime.now();
      final id = widget.initialConfig?.id ??
          nameText.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
      
      Map<String, dynamic> headersJson = {};
      try {
        if (_headers.text.trim().isNotEmpty) {
          headersJson = jsonDecode(_headers.text.trim()) as Map<String, dynamic>;
        }
      } catch (_) {
        // Fallback to empty if parse error
      }
      final customHeaders = Map<String, String>.from(
        headersJson.map((k, v) => MapEntry(k.toString(), v.toString())),
      );

      void putQuery(String key, String value) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) customHeaders['query.$key'] = trimmed;
      }

      putQuery('api_key', _apiKey.text);
      putQuery('user_id', _userId.text);
      putQuery('login', _login.text);

      final config = ContentProviderConfig(
        id: id,
        name: nameText,
        baseUrl: _baseUrl.text.trim(),
        apiType: _apiType,
        enabled: _enabled,
        priority: int.tryParse(_priority.text) ?? 10,
        timeoutSeconds: int.tryParse(_timeout.text) ?? 20,
        customHeaders: customHeaders,
        createdAt: widget.initialConfig?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(providersControllerProvider.notifier).save(config);
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/providers');
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, String> _visibleHeaders(Map<String, String> headers) {
    return Map<String, String>.from(headers)
      ..removeWhere((key, _) => key.startsWith('query.'));
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.name,
    required this.color,
    required this.onTap,
  });

  final String name;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.16 : 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.40 : 0.28),
              width: 1,
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
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormLiquidCard extends StatelessWidget {
  const _FormLiquidCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.30)
                : accentColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      theme.colorScheme.surfaceContainerHigh
                          .withValues(alpha: 0.65),
                      theme.colorScheme.surfaceContainerLow
                          .withValues(alpha: 0.40),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.90),
                      Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.80),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.32),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(icon, size: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.minLines = 1,
    this.maxLines = 1,
    this.isMonospace = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int minLines;
  final int maxLines;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 14,
        fontFamily: isMonospace ? 'monospace' : null,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _GlassDropdown extends StatelessWidget {
  const _GlassDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: isDark
          ? theme.colorScheme.surfaceContainerHighest
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.hub_outlined, size: 18),
        filled: true,
        fillColor: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
