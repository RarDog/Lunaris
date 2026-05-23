import '../../core/http/dio_client.dart';
import '../models/content_provider_config.dart';
import 'content_provider.dart';
import 'custom_provider.dart';
import 'danbooru_provider.dart';
import 'gelbooru_provider.dart';
import 'rule34_provider.dart';

class ProviderFactory {
  ContentProvider create(ContentProviderConfig config) {
    final headers = Map<String, String>.from(config.customHeaders)
      ..removeWhere((key, _) => key.startsWith('query.'));
    final queryParameters = {
      for (final entry in config.customHeaders.entries)
        if (entry.key.startsWith('query.') && entry.value.trim().isNotEmpty)
          entry.key.substring('query.'.length): entry.value.trim(),
    };
    final client = DioClient(
      baseUrl: config.baseUrl,
      timeout: Duration(seconds: config.timeoutSeconds),
      headers: headers,
    );
    return switch (config.apiType.toLowerCase()) {
      'gelbooru' => GelbooruProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        ),
      'rule34' => Rule34Provider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        ),
      'danbooru' => DanbooruProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          dioClient: client,
          queryParameters: queryParameters,
        ),
      _ => UnsupportedCustomProvider(
          id: config.id,
          name: config.name,
          baseUrl: config.baseUrl,
          apiType: config.apiType,
        ),
    };
  }
}
