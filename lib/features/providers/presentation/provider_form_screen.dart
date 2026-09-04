import 'dart:convert';

import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.initialConfig == null ? 'New provider' : 'Edit provider')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(
              controller: _baseUrl,
              decoration: const InputDecoration(labelText: 'Base URL')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _apiType,
            decoration: const InputDecoration(labelText: 'API type'),
            items: const [
              DropdownMenuItem(
                  value: 'gelbooru', child: Text('gelbooru-compatible')),
              DropdownMenuItem(
                  value: 'rule34', child: Text('rule34-compatible')),
              DropdownMenuItem(
                  value: 'paheal', child: Text('Rule34 Paheal HTML')),
              DropdownMenuItem(
                  value: 'realbooru_html', child: Text('realbooru HTML')),
              DropdownMenuItem(
                  value: 'danbooru', child: Text('danbooru-compatible')),
              DropdownMenuItem(
                  value: 'moebooru', child: Text('moebooru-compatible')),
              DropdownMenuItem(value: 'e621', child: Text('e621/e926')),
              DropdownMenuItem(value: 'kemono', child: Text('Kemono artists')),
              DropdownMenuItem(value: 'coomer', child: Text('Coomer artists')),
              DropdownMenuItem(value: 'custom', child: Text('custom')),
            ],
            onChanged: (value) =>
                setState(() => _apiType = value ?? 'gelbooru'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _enabled,
            title: const Text('Enabled'),
            onChanged: (value) => setState(() => _enabled = value),
          ),
          TextField(
            controller: _priority,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Priority'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _timeout,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Timeout seconds'),
          ),
          const SizedBox(height: 12),
          Text('Provider API credentials',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKey,
            decoration: const InputDecoration(
              labelText: 'API key',
              helperText:
                  'Gelbooru/Rule34/Danbooru API key (Account -> Options)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _userId,
            decoration: const InputDecoration(
              labelText: 'User ID',
              helperText:
                  'Gelbooru/Rule34 User ID (required for API access, see Options)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _login,
            decoration: const InputDecoration(
              labelText: 'Login',
              helperText: 'Danbooru-compatible APIs may require login',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _headers,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Custom headers JSON'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save provider'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final id = widget.initialConfig?.id ??
        _name.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final headersJson =
        jsonDecode(_headers.text.trim().isEmpty ? '{}' : _headers.text);
    final customHeaders = Map<String, String>.from(headersJson as Map);
    void putQuery(String key, String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) customHeaders['query.$key'] = trimmed;
    }

    putQuery('api_key', _apiKey.text);
    putQuery('user_id', _userId.text);
    putQuery('login', _login.text);
    final config = ContentProviderConfig(
      id: id,
      name: _name.text.trim(),
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
    if (mounted) context.go('/providers');
  }

  Map<String, String> _visibleHeaders(Map<String, String> headers) {
    return Map<String, String>.from(headers)
      ..removeWhere((key, _) => key.startsWith('query.'));
  }
}
