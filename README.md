# Lunaris

Lunaris — локальное Flutter-приложение для просмотра booru, gelbooru, rule34-подобных источников и artist-архивов в Pinterest-стиле.

Приложение не использует отдельный backend-сервер. Вся логика живет внутри Flutter: API-провайдеры, локальный кеш metadata, избранное, коллекции, история просмотров, фильтры, диагностика, загрузки и обновления.

## Что умеет

- Masonry feed с несколькими провайдерами и естественно перемешанной выдачей.
- Поиск тегов через chip-input с подсказками из активных API.
- Избранное, история просмотров, коллекции и пакетное добавление в коллекции.
- Smart blacklist/whitelist по тегам, группам тегов, рейтингу, провайдеру, типу файла и score.
- Details viewer для фото, GIF, видео и SWF на Windows.
- Удобный видеоплеер с fullscreen, repeat, mute, half-volume и сохранением настроек.
- Mobile image zoom: pinch-to-zoom и double tap в details.
- Опциональное автоскачивание новых favorites с отдельным удалением локального файла без удаления из избранного.
- Отдельная вкладка Artists для Kemono/Coomer без смешивания с обычной booru-лентой.
- Управление провайдерами, health-check и provider diagnostics.
- Кастомизация интерфейса: тема, язык RU/EN, акцентный цвет, видимые вкладки, beta/experimental обновления.
- Экспорт и импорт настроек JSON.
- Проверка Gitea Releases и скачивание APK/Windows installer прямо из приложения.

## Скачать

Готовые сборки лежат в Gitea Releases:

[Lunaris 2.0.1](https://gitea.rardogsynapse.online/RarDog/RuleGelApp/releases/tag/v2.0.1)

- `Lunaris-v2.0.1.apk` — APK для Android.
- `LunarisSetup-v2.0.1.exe` — установщик для Windows.
- `LunarisPortable-v2.0.1.zip` — portable-версия для Windows.

## Провайдеры

Обычный feed:

- Gelbooru
- Rule34
- Safebooru
- Konachan
- Yande.re
- e621 / e926
- Xbooru
- CosBooru
- Realbooru отключен по умолчанию, если публичный API недоступен

Artists flow:

- Kemono
- Coomer

Kemono/Coomer остаются отдельным разделом Artists и не попадают в общий booru feed.

## Архитектура

- `lib/core` — HTTP, база, кеш, ошибки, Result и утилиты.
- `lib/backend/models` — доменные модели.
- `lib/backend/providers` — API-провайдеры и ProviderManager.
- `lib/backend/repositories` — доступ к локальному Isar-хранилищу.
- `lib/backend/services` — Feed/Search/Favorites/Collections/Settings/Diagnostics/Downloads/Updates.
- `lib/backend/di` — Riverpod providers для backend/core.
- `lib/app` — приложение, роутер, тема, локализация, motion и responsive helpers.
- `lib/shared/widgets` — общие UI-компоненты.
- `lib/features` — экраны и контроллеры фич.

## Запуск

```bash
flutter pub get
flutter run -d windows
flutter run -d android
```

## Сборка

```bash
flutter analyze
flutter test
flutter build apk
flutter build windows
```

Windows installer собирается через Inno Setup:

```powershell
ISCC.exe installer\Lunaris.iss
```

## Как добавить провайдера

1. Создать класс, реализующий `ContentProvider`.
2. Добавить mapper к единой модели `Post`.
3. Зарегистрировать `apiType` в `ProviderFactory`.
4. Добавить seed config в `ProviderRepository`, если провайдер нужен по умолчанию.
5. Добавить тесты parser/provider factory.

## Безопасность

- Feed работает только с metadata/preview и не скачивает original/full files автоматически.
- Загрузка файлов происходит только по явному действию пользователя или при включенной настройке auto-download favorites.
- Приложение уважает API и rate limits сайтов.
- NSFW/blur/blacklist настраиваются локально.
- API keys/custom headers хранятся локально и экспортируются только через явный export settings.
- Локальные пути скачанных файлов не попадают в JSON export/import.
