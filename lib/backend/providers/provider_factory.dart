import 'dart:convert';

import '../../core/http/dio_client.dart';
import '../models/content_provider_config.dart';
import 'content_provider.dart';
import 'custom_provider.dart';
import 'danbooru_provider.dart';
import 'e621_provider.dart';
import 'gelbooru_provider.dart';
import 'moebooru_provider.dart';
import 'pawchive_provider.dart';
import 'realbooru_html_provider.dart';
import 'rule34_provider.dart';
import 'rule34_paheal_provider.dart';

class ProviderFactory {
  ContentProvider create(ContentProviderConfig config) {
    final headers = Map<String, String>.from(config.customHeaders)
      ..removeWhere((key, _) => key.startsWith('query.'));
    final queryParameters = {
      for (final entry in config.customHeaders.entries)
        if (entry.key.startsWith('query.') && entry.value.trim().isNotEmpty)
          entry.key.substring('query.'.length): entry.value.trim(),
    };

    if (config.apiType.toLowerCase() == 'e621') {
      final login = queryParameters['login'] ?? headers['login'];
      final apiKey = queryParameters['api_key'] ?? headers['api_key'];
      if (login != null && apiKey != null && login.isNotEmpty && apiKey.isNotEmpty) {
        final basicAuth = base64Encode(utf8.encode('$login:$apiKey'));
        headers['Authorization'] = 'Basic $basicAuth';
        headers['User-Agent'] = 'Prisma/3.6.6 (by $login on e621)';
      }
    }

    final client = DioClient(
      baseUrl: config.baseUrl,
      timeout: Duration(seconds: config.timeoutSeconds),
      headers: headers,
    );
    switch (config.apiType.toLowerCase()) {
      case 'gelbooru':
        return GelbooruProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        );
      case 'rule34':
        return Rule34Provider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        );
      case 'paheal':
      case 'rule34_paheal':
        return Rule34PahealProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
        );
      case 'realbooru_html':
        return RealbooruHtmlProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
        );
      case 'danbooru':
        return DanbooruProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        );
      case 'moebooru':
        return MoebooruProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        );
      case 'e621':
        return E621Provider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        );
      case 'pawchive':
        return PawchiveProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        );
      default:
        return UnsupportedCustomProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          apiType: config.apiType,
        );
    }
  }
}
