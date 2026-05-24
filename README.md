# RuleGel

RuleGel — единое Flutter-приложение для просмотра booru/gelbooru/rule34-подобных источников в Pinterest-стиле.

Приложение не использует отдельный backend-сервер. Вся логика работает локально внутри Flutter: провайдеры API, кэш metadata, избранное, коллекции, история, настройки, диагностика и фильтры.

## Возможности

- Pinterest-like masonry feed с несколькими провайдерами.
- Поиск по тегам через удобные chip-теги: ввёл тег, нажал пробел или Enter, тег стал отдельным элементом.
- Подсказки тегов из provider API.
- Избранное, коллекции и история просмотренных постов.
- Smart blacklist и whitelist с правилами по тегам, рейтингу, провайдеру, типу файла и score.
- Детальный просмотр фото, GIF и видео.
- Видео-плеер с fullscreen, repeat, mute и понижением громкости.
- Desktop-only просмотр `.swf` через Ruffle/WebView на Windows.
- Управление провайдерами, health-check и provider diagnostics.
- Экспорт и импорт настроек.
- Android и Windows сборки.

## Скачать

Готовые сборки лежат в Gitea Releases:

[RuleGel v0.3.0](https://gitea.rardogsynapse.online/RarDog/RuleGelApp/releases/tag/v0.3.0-tag-chips-swf)

- `RuleGelSetup.exe` — установщик для Windows.
- `RuleGel-v0.3.0.apk` — APK для Android.

## Стек

- Flutter и Dart
- Riverpod
- go_router
- Dio
- Isar
- cached_network_image
- flutter_staggered_grid_view
- media_kit
- webview_windows для SWF/Ruffle на Windows
- connectivity_plus
- freezed/json_serializable/build_runner

## Архитектура

RuleGel — Flutter-монолит. UI не дублирует backend-логику, а вызывает локальные сервисы через Riverpod.

Основные слои:

- `lib/core` — HTTP, база, кэш, ошибки, Result-тип и утилиты.
- `lib/backend/models` — доменные модели.
- `lib/backend/providers` — API-провайдеры и ProviderManager.
- `lib/backend/repositories` — доступ к локальному Isar-хранилищу.
- `lib/backend/services` — Feed/Search/Favorites/Collections/Settings/Diagnostics.
- `lib/backend/di` — Riverpod providers для backend/core.
- `lib/app` — приложение, роутер, тема и responsive helpers.
- `lib/shared/widgets` — общие UI-компоненты.
- `lib/features` — экраны и контроллеры фич.

## Экраны

- `/` — главный feed.
- `/search` — поиск и recent searches.
- `/post/:providerId/:postId` — детальный просмотр поста.
- `/favorites` — избранное.
- `/viewed` — история просмотренных постов.
- `/collections` — коллекции.
- `/collections/:collectionId` — посты внутри коллекции.
- `/providers` — управление провайдерами.
- `/providers/new` — добавление/редактирование провайдера.
- `/providers/check` — проверка провайдеров и diagnostics.
- `/settings` — настройки.

## Провайдеры по умолчанию

- Gelbooru — `https://gelbooru.com`
- Rule34 — `https://api.rule34.xxx`
- Safebooru — `https://safebooru.org`
- Konachan — `https://konachan.com`
- Yande.re — `https://yande.re`
- e621 — `https://e621.net`
- e926 — `https://e926.net`

Поддерживаемые `apiType`:

- `gelbooru`
- `rule34`
- `danbooru`
- `moebooru`
- `e621`

Один упавший провайдер не ломает общий feed: ошибки сохраняются в diagnostics, а остальные провайдеры продолжают отдавать посты.

## Как добавить провайдера

1. Добавить mapper в `lib/backend/mappers`, если формат ответа отличается.
2. Реализовать `ContentProvider` в `lib/backend/providers`.
3. Зарегистрировать новый `apiType` в `ProviderFactory`.
4. Добавить config через `ProviderManager` или UI Providers.

Интерфейс провайдера:

```dart
abstract class ContentProvider {
  String get id;
  String get name;
  String get baseUrl;

  Future<List<Post>> searchPosts({
    required List<String> tags,
    required int page,
    int limit = 50,
    String? rating,
  });

  Future<Post?> getPost(String id);
  Future<ProviderHealth> checkHealth();
}
```

## Локальная база

Isar хранит:

- configs провайдеров;
- health status и diagnostics;
- cached metadata постов;
- избранное;
- коллекции и связи collection-post;
- историю поиска;
- историю просмотренных постов;
- app settings.

Кэш хранит только metadata. Оригинальные медиафайлы не скачиваются автоматически.

## Использование сервисов из UI

UI получает сервисы через Riverpod из `lib/backend/di/backend_providers.dart`.

Пример feed:

```dart
final result = await ref.read(feedServiceProvider).refresh(
  tags: ['touhou', 'hakurei_reimu'],
  rating: 'safe',
);
```

Пример избранного:

```dart
await ref.read(favoriteServiceProvider).addFavorite(post);

final saved = await ref
    .read(favoriteServiceProvider)
    .isFavorite(post.id, post.providerId);
```

Пример настроек:

```dart
final settings = ref.read(settingsServiceProvider);
final exported = await settings.exportSettingsToJson();
await settings.importSettingsFromJson(exported.data);
```

## Сборка и запуск

Установить зависимости:

```bash
flutter pub get
```

Сгенерировать Isar-код:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Запустить:

```bash
flutter run -d windows
flutter run -d android
```

Собрать релиз:

```bash
flutter build windows
flutter build apk
```

Собрать Windows installer:

```powershell
& "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe" installer\RuleGel.iss
```

## Важные заметки

- На Windows для Flutter plugins может понадобиться Developer Mode.
- Android-сборка требует Android SDK и принятые `flutter doctor --android-licenses`.
- Linux build нужно собирать на Linux-хосте.
- Если путь проекта содержит апостроф, Flutter Windows/test tooling может капризничать. Для сборки можно использовать junction-путь без спецсимволов.
- SWF работает только на Windows. На Android он намеренно отключён.
- Для SWF на Windows может понадобиться Microsoft WebView2 Runtime.

## Безопасность

- RuleGel использует публичные API и metadata.
- Приложение не обходит ограничения сайтов.
- Оригинальные файлы скачиваются только вручную по действию пользователя.
- Dio использует нормальный User-Agent.
- Retry/backoff ограничены.
- NSFW/blur/filter настройки работают локально.

## Тесты

```bash
flutter analyze
flutter test
```

В текущей версии покрыты backend-сервисы, provider parsing, smart blacklist, viewed history и tag chip input.
