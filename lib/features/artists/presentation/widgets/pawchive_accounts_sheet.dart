import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app.dart';
import '../../../../backend/backend.dart';
import '../../../settings/presentation/settings_controller.dart';

class PawchiveAccountsSheet extends ConsumerStatefulWidget {
  const PawchiveAccountsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PawchiveAccountsSheet(),
    );
  }

  @override
  ConsumerState<PawchiveAccountsSheet> createState() =>
      _PawchiveAccountsSheetState();
}

class _PawchiveAccountsSheetState extends ConsumerState<PawchiveAccountsSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _addTabController;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cookieController = TextEditingController();

  bool _isAdding = false;
  bool _obscurePassword = true;
  String? _syncingAccountId;
  String? _pushingAccountId;
  bool _syncingAll = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _addTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _addTabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _cookieController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginCredentials() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Введите логин и пароль');
      return;
    }

    setState(() {
      _isAdding = true;
      _errorMessage = null;
    });

    try {
      final syncService = ref.read(pawchiveSyncServiceProvider);
      final account = await syncService.loginWithCredentials(
        username: username,
        password: password,
      );

      final settings =
          ref.read(appSettingsProvider).value ?? AppSettings.defaults;
      final existingAccounts = settings.parsedPawchiveAccounts.where((a) => a.id != account.id).toList();
      // Set as active
      final updatedList = [
        account.copyWith(isActive: true),
        ...existingAccounts.map((a) => a.copyWith(isActive: false)),
      ];

      var newSettings = settings.copyWith(
        pawchiveAccounts:
            updatedList.map((a) => jsonEncode(a.toJson())).toList(),
      );

      // Perform initial sync
      final syncResult = await syncService.syncAccountFavorites(
        account: account,
        settings: newSettings,
      );
      if (syncResult.isSuccess) {
        newSettings = syncResult.updatedSettings;
      }

      await ref
          .read(settingsControllerProvider.notifier)
          .saveSettings(newSettings);

      _usernameController.clear();
      _passwordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Аккаунт @${account.username} добавлен! Синхронизировано ${account.syncedArtistsCount} авторов.',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('StateError: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _handleLoginCookie() async {
    final cookie = _cookieController.text.trim();
    final username = _usernameController.text.trim();
    if (cookie.isEmpty) {
      setState(() => _errorMessage = 'Введите сессионную куку');
      return;
    }

    setState(() {
      _isAdding = true;
      _errorMessage = null;
    });

    try {
      final syncService = ref.read(pawchiveSyncServiceProvider);
      final account = await syncService.loginWithSession(
        sessionCookie: cookie,
        username: username.isEmpty ? 'Pawchive User' : username,
      );

      final settings =
          ref.read(appSettingsProvider).value ?? AppSettings.defaults;
      final existingAccounts = settings.parsedPawchiveAccounts.where((a) => a.id != account.id).toList();
      final updatedList = [
        account.copyWith(isActive: true),
        ...existingAccounts.map((a) => a.copyWith(isActive: false)),
      ];

      var newSettings = settings.copyWith(
        pawchiveAccounts:
            updatedList.map((a) => jsonEncode(a.toJson())).toList(),
      );

      final syncResult = await syncService.syncAccountFavorites(
        account: account,
        settings: newSettings,
      );
      if (syncResult.isSuccess) {
        newSettings = syncResult.updatedSettings;
      }

      await ref
          .read(settingsControllerProvider.notifier)
          .saveSettings(newSettings);

      _cookieController.clear();
      _usernameController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Кука сохранена! Синхронизировано ${account.syncedArtistsCount} авторов.',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('StateError: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _syncSingleAccount(PawchiveAccount account) async {
    setState(() => _syncingAccountId = account.id);
    try {
      final syncService = ref.read(pawchiveSyncServiceProvider);
      final settings =
          ref.read(appSettingsProvider).value ?? AppSettings.defaults;
      final result = await syncService.syncAccountFavorites(
        account: account,
        settings: settings,
      );

      if (result.isSuccess) {
        await ref
            .read(settingsControllerProvider.notifier)
            .saveSettings(result.updatedSettings);
        if (mounted) {
          final pushedMsg = result.pushedToRemoteCount > 0
              ? ', выгружено в Pawchive: +${result.pushedToRemoteCount}'
              : '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Синхронизировано: ${result.totalSyncedCount} авторов (+${result.newlyAddedToLocal} новых в приложении$pushedMsg)',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка синхронизации: ${result.errorMessage}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _syncingAccountId = null);
      }
    }
  }

  Future<void> _pushFavoritesToAccount(PawchiveAccount account) async {
    final settings =
        ref.read(appSettingsProvider).value ?? AppSettings.defaults;
    final totalLocal = settings.favoriteArtists.length;
    if (totalLocal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('В локальном избранном пока нет авторов')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выгрузить избранное в Pawchive?'),
        content: Text(
          'Все локальные авторы из приложения ($totalLocal) будут добавлены в избранное аккаунта @${account.username} на сервере Pawchive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Выгрузить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _pushingAccountId = account.id);
    try {
      final syncService = ref.read(pawchiveSyncServiceProvider);
      final result = await syncService.pushLocalFavoritesToAccount(
        account: account,
        settings: settings,
      );

      if (result.isSuccess) {
        if (result.updatedSettings != null) {
          await ref
              .read(settingsControllerProvider.notifier)
              .saveSettings(result.updatedSettings!);
        }

        if (mounted) {
          if (result.pushedCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Выгружено ${result.pushedCount} авторов в @${account.username}! Всего в аккаунте: ${result.totalRemoteCount}.',
                ),
                backgroundColor: Colors.green.shade700,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Все авторы (${result.totalLocalCandidates}) уже есть в аккаунте @${account.username}.',
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка выгрузки: ${result.errorMessage}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _pushingAccountId = null);
      }
    }
  }

  Future<void> _syncAllAccounts() async {
    setState(() => _syncingAll = true);
    try {
      final syncService = ref.read(pawchiveSyncServiceProvider);
      final settings =
          ref.read(appSettingsProvider).value ?? AppSettings.defaults;
      final result = await syncService.syncAllAccounts(settings: settings);

      if (result.isSuccess) {
        await ref
            .read(settingsControllerProvider.notifier)
            .saveSettings(result.updatedSettings);
        if (mounted) {
          final pushedMsg = result.pushedToRemoteCount > 0
              ? ', выгружено в Pawchive: +${result.pushedToRemoteCount}'
              : '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Все аккаунты синхронизированы! Всего: ${result.totalSyncedCount} (+${result.newlyAddedToLocal} новых в приложении$pushedMsg)',
              ),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка синхронизации: ${result.errorMessage}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _syncingAll = false);
      }
    }
  }

  Future<void> _setActiveAccount(PawchiveAccount target) async {
    final settings =
        ref.read(appSettingsProvider).value ?? AppSettings.defaults;
    final updatedList = settings.parsedPawchiveAccounts.map((a) {
      return a.copyWith(isActive: a.id == target.id);
    }).toList();

    await ref.read(settingsControllerProvider.notifier).saveSettings(
          settings.copyWith(
            pawchiveAccounts:
                updatedList.map((a) => jsonEncode(a.toJson())).toList(),
          ),
        );
  }

  Future<void> _removeAccount(PawchiveAccount target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить аккаунт Pawchive?'),
        content: Text(
          'Вы уверены, что хотите удалить аккаунт @${target.username}? Локальные авторы останутся в приложении.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final settings =
        ref.read(appSettingsProvider).value ?? AppSettings.defaults;
    final filtered =
        settings.parsedPawchiveAccounts.where((a) => a.id != target.id).toList();

    // If active was removed, make first remaining active
    if (filtered.isNotEmpty && !filtered.any((a) => a.isActive)) {
      filtered[0] = filtered[0].copyWith(isActive: true);
    }

    await ref.read(settingsControllerProvider.notifier).saveSettings(
          settings.copyWith(
            pawchiveAccounts:
                filtered.map((a) => jsonEncode(a.toJson())).toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings =
        ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
    final accounts = settings.parsedPawchiveAccounts;

    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: accounts.isEmpty ? 0.8 : 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.cloud_sync_rounded,
                        color: scheme.onPrimaryContainer,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Аккаунты Pawchive',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Синхронизация авторов и избранного',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (accounts.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _syncingAll ? null : _syncAllAccounts,
                        icon: _syncingAll
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync_rounded, size: 20),
                        tooltip: 'Синхронизировать все аккаунты',
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),

              // Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + keyboardPadding),
                  children: [
                    // Connected accounts section
                    if (accounts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          'ПОДКЛЮЧЁННЫЕ АККАУНТЫ (${accounts.length})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ...accounts.map((acc) => _buildAccountCard(acc, scheme, theme)),
                      const SizedBox(height: 12),

                      // Two-way sync & Export to Pawchive panel
                      Card(
                        elevation: 0,
                        color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: scheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.swap_vert_rounded, size: 20, color: scheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Двусторонняя синхронизация',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: settings.pawchiveBidirectionalSync,
                                    onChanged: (val) async {
                                      final newSettings = settings.copyWith(
                                        pawchiveBidirectionalSync: val,
                                      );
                                      await ref
                                          .read(settingsControllerProvider.notifier)
                                          .saveSettings(newSettings);
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                'При обычной синхронизации также выгружать всех локальных авторов на сервер Pawchive.',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: (_syncingAll || _pushingAccountId != null)
                                    ? null
                                    : () {
                                        final target = settings.activePawchiveAccount ?? accounts.first;
                                        _pushFavoritesToAccount(target);
                                      },
                                icon: _pushingAccountId != null
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.cloud_upload_rounded, size: 18),
                                label: Text(
                                  'Выгрузить избранное (${settings.favoriteArtists.length}) в @${(settings.activePawchiveAccount ?? accounts.first).username}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Add account section
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        accounts.isEmpty ? 'ДОБАВИТЬ АККАУНТ' : 'ДОБАВИТЬ ЕЩЁ АККАУНТ',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      color: scheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TabBar(
                              controller: _addTabController,
                              tabs: const [
                                Tab(text: 'Логин и пароль'),
                                Tab(text: 'Session Cookie'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: scheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      size: 18,
                                      color: scheme.onErrorContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: scheme.onErrorContainer,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              height: 190,
                              child: TabBarView(
                                controller: _addTabController,
                                children: [
                                  // Tab 1: Username & Password
                                  Column(
                                    children: [
                                      TextField(
                                        controller: _usernameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Имя пользователя',
                                          prefixIcon: Icon(Icons.person_outline_rounded),
                                          isDense: true,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: 'Пароль',
                                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                                          isDense: true,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                            ),
                                            onPressed: () => setState(
                                              () => _obscurePassword = !_obscurePassword,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      FilledButton.icon(
                                        onPressed: _isAdding ? null : _handleLoginCredentials,
                                        icon: _isAdding
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Icon(Icons.login_rounded),
                                        label: const Text('Войти и синхронизировать'),
                                      ),
                                    ],
                                  ),
                                  // Tab 2: Session Cookie
                                  Column(
                                    children: [
                                      TextField(
                                        controller: _usernameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Никнейм (необязательно)',
                                          prefixIcon: Icon(Icons.badge_outlined),
                                          isDense: true,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _cookieController,
                                        maxLines: 2,
                                        decoration: const InputDecoration(
                                          labelText: 'Сессионная кука',
                                          hintText: 'session=ey... или значение куки',
                                          prefixIcon: Icon(Icons.cookie_outlined),
                                          isDense: true,
                                        ),
                                      ),
                                      const Spacer(),
                                      FilledButton.icon(
                                        onPressed: _isAdding ? null : _handleLoginCookie,
                                        icon: _isAdding
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Icon(Icons.check_circle_outline_rounded),
                                        label: const Text('Сохранить куку'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountCard(PawchiveAccount acc, ColorScheme scheme, ThemeData theme) {
    final isSyncing = _syncingAccountId == acc.id;
    final isPushing = _pushingAccountId == acc.id;
    final isBusy = isSyncing || isPushing;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: acc.isActive
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: acc.isActive
              ? scheme.primary.withValues(alpha: 0.6)
              : scheme.outlineVariant.withValues(alpha: 0.3),
          width: acc.isActive ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: acc.isActive ? scheme.primary : scheme.surfaceContainerHighest,
          foregroundColor: acc.isActive ? scheme.onPrimary : scheme.onSurfaceVariant,
          child: Text(
            acc.username.isNotEmpty ? acc.username[0].toUpperCase() : 'P',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                acc.username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (acc.isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Активен',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'Авторов: ${acc.syncedArtistsCount} • ${acc.lastSyncedAt != null ? _formatDate(acc.lastSyncedAt!) : "не синхр."}',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: const EdgeInsets.all(6),
              iconSize: 18,
              icon: isPushing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              tooltip: 'Выгрузить локальное избранное в этот аккаунт',
              onPressed: isBusy ? null : () => _pushFavoritesToAccount(acc),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: const EdgeInsets.all(6),
              iconSize: 18,
              icon: isSyncing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
              tooltip: 'Синхронизировать этот аккаунт',
              onPressed: isBusy ? null : () => _syncSingleAccount(acc),
            ),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 32),
              iconSize: 18,
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (val) {
                if (val == 'active') {
                  _setActiveAccount(acc);
                } else if (val == 'push') {
                  _pushFavoritesToAccount(acc);
                } else if (val == 'delete') {
                  _removeAccount(acc);
                }
              },
              itemBuilder: (ctx) => [
                if (!acc.isActive)
                  const PopupMenuItem(
                    value: 'active',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Сделать активным'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'push',
                  child: Row(
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Выгрузить в Pawchive'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Удалить аккаунт', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inMinutes < 1) return 'только что';
    if (now.difference(dt).inHours < 1) return '${now.difference(dt).inMinutes} мин назад';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
