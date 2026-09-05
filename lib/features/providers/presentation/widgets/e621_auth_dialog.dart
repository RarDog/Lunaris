import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../backend/models/content_provider_config.dart';

class E621AuthDialog extends StatefulWidget {
  const E621AuthDialog({
    required this.config,
    required this.onSaved,
    super.key,
  });

  final ContentProviderConfig config;
  final ValueChanged<ContentProviderConfig> onSaved;

  static Future<void> show(
    BuildContext context, {
    required ContentProviderConfig config,
    required ValueChanged<ContentProviderConfig> onSaved,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => E621AuthDialog(
        config: config,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<E621AuthDialog> createState() => _E621AuthDialogState();
}

class _E621AuthDialogState extends State<E621AuthDialog> {
  late final TextEditingController _loginController;
  late final TextEditingController _apiKeyController;
  bool _obscureKey = true;
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    final login = widget.config.customHeaders['query.login'] ?? '';
    final apiKey = widget.config.customHeaders['query.api_key'] ?? '';
    _loginController = TextEditingController(text: login);
    _apiKeyController = TextEditingController(text: apiKey);
  }

  @override
  void dispose() {
    _loginController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testAndSave() async {
    final login = _loginController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (login.isEmpty || apiKey.isEmpty) {
      setState(() {
        _statusMessage = 'Укажите логин и API ключ';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: widget.config.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$login:$apiKey'))}',
            'User-Agent': 'Prisma/3.6.6 (by $login on e621)',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await dio.get<dynamic>('/posts.json', queryParameters: {
        'limit': 1,
      });

      if (response.statusCode == 200) {
        final updatedHeaders =
            Map<String, String>.from(widget.config.customHeaders)
              ..['query.login'] = login
              ..['query.api_key'] = apiKey;

        final updatedConfig = widget.config.copyWith(
          customHeaders: updatedHeaders,
          updatedAt: DateTime.now(),
        );

        widget.onSaved(updatedConfig);

        setState(() {
          _isLoading = false;
          _isSuccess = true;
          _statusMessage = 'Успешно авторизован! Лимит тегов снят.';
        });

        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _statusMessage =
              'Ошибка проверки (код ${response.statusCode}). Проверьте логин и ключ.';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        if (e.response?.statusCode == 401) {
          _statusMessage = 'Неверный логин или API-ключ (401 Unauthorized)';
        } else if (e.response?.statusCode == 403) {
          _statusMessage = 'Доступ запрещен (403 Forbidden). Проверьте API access в профиле e621.';
        } else {
          _statusMessage = 'Ошибка подключения: ${e.message ?? e.toString()}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _statusMessage = 'Ошибка: $e';
      });
    }
  }

  void _clearAuth() {
    final updatedHeaders =
        Map<String, String>.from(widget.config.customHeaders)
          ..remove('query.login')
          ..remove('query.api_key');

    final updatedConfig = widget.config.copyWith(
      customHeaders: updatedHeaders,
      updatedAt: DateTime.now(),
    );

    widget.onSaved(updatedConfig);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLogin = widget.config.customHeaders['query.login'];
    final isAlreadyAuthorized =
        currentLogin != null && currentLogin.trim().isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2430).withValues(alpha: 0.90)
                    : Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF0055AA).withValues(alpha: 0.40)
                      : const Color(0xFF0055AA).withValues(alpha: 0.20),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0055AA).withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title row
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0055AA), Color(0xFF0077EE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0055AA).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.vpn_key_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Авторизация e621',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              isAlreadyAuthorized
                                  ? 'Вход выполнен как $currentLogin'
                                  : 'Снятие ограничений поиска и функций',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isAlreadyAuthorized
                                    ? const Color(0xFF10B981)
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isAlreadyAuthorized
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Benefits badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0055AA).withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0055AA).withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BenefitRow(
                          icon: Icons.check_circle_outline_rounded,
                          text: 'Снятие лимита в 2 тега (поиск по 4–6+ тегам)',
                        ),
                        SizedBox(height: 6),
                        _BenefitRow(
                          icon: Icons.favorite_border_rounded,
                          text: 'Серверная синхронизация Избранного (Favorites)',
                        ),
                        SizedBox(height: 6),
                        _BenefitRow(
                          icon: Icons.thumb_up_alt_outlined,
                          text: 'Голосование за посты (Upvote / Downvote)',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Username field
                  TextField(
                    controller: _loginController,
                    decoration: InputDecoration(
                      labelText: 'Имя пользователя (Username на e621)',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      filled: true,
                      fillColor: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // API Key field
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      labelText: 'API Ключ (API Key)',
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                        onPressed: () =>
                            setState(() => _obscureKey = !_obscureKey),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // How to get API key link
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        launchUrl(
                          Uri.parse('https://e621.net/users/home'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      label: const Text(
                        'Как получить ключ (e621 -> Manage API Access)',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),

                  if (_statusMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isSuccess
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSuccess
                              ? const Color(0xFF10B981).withValues(alpha: 0.40)
                              : const Color(0xFFEF4444).withValues(alpha: 0.40),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccess
                                ? Icons.check_circle_rounded
                                : Icons.error_outline_rounded,
                            size: 16,
                            color: _isSuccess
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: _isSuccess
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      if (isAlreadyAuthorized) ...[
                        TextButton.icon(
                          onPressed: _isLoading ? null : _clearAuth,
                          icon: const Icon(Icons.logout_rounded,
                              size: 16, color: Color(0xFFEF4444)),
                          label: const Text('Выйти',
                              style: TextStyle(color: Color(0xFFEF4444))),
                        ),
                        const Spacer(),
                      ] else
                        const Spacer(),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _testAndSave,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text(_isLoading ? 'Проверка...' : 'Сохранить'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0055AA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
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

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF0077EE)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
