# 🌙 Lunaris

<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="128" height="128" alt="Lunaris Logo" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.35);" />
</p>

<p align="center">
  <strong>Современный кроссплатформенный клиент для Booru и Creator-архивов нового поколения</strong><br>
  Плавный Pinterest-стиль, интеграция Pawchive 2.0, двусторонняя синхронизация, интеллектуальное автообновление и воспроизведение медиа без задержек.
</p>

<p align="center">
  <a href="https://github.com/RarDog/Lunaris/releases"><img src="https://img.shields.io/badge/Version-3.0.4-8A2BE2?style=for-the-badge&logo=semver&logoColor=white" alt="Version 3.0.4" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Linux%20%7C%20Windows-00C853?style=for-the-badge" alt="Platforms" />
  <a href="https://github.com/RarDog/Lunaris/wiki"><img src="https://img.shields.io/badge/Wiki-Documentation-FF6F00?style=for-the-badge&logo=gitbook&logoColor=white" alt="Wiki" /></a>
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License MIT" />
</p>

---

## 🚀 Что нового в Lunaris 3.0 (Major Release)

### 🎨 Дизайн 2.0
- **Современный визуальный стиль**: Полный переход на squircle-карточки, адаптивную цветовую палитру и улучшенную Material You динамическую тему.
- **Интеллектуальный Action Dock 2.0**: Компактный док ключевых действий под контентом с быстрым доступом к скачиванию, шерингу, тегам и инфо.
- **Плавные анимации и микро-взаимодействия**: Открытие медиа с эффектом Hero, интерактивное листание свайпами и анимированный лайк по двойному тапу.

### 🐾 Глубокая интеграция Pawchive 2.0
- **Мульти-аккаунты**: Поддержка авторизации по логину и паролю, а также прямому вводу `Session Cookie`.
- **Двусторонняя синхронизация (Two-Way Sync)**: Автоматическая синхронизация избранного между локальной базой Lunaris и профилем Pawchive. Новые авторы с сервера добавляются в приложение, а локальные авторы выгружаются на сервер в один тап.
- **Моментальная синхронизация**: При нажатии кнопки «В избранное» у любого автора (Fanbox, Patreon, Fantia, Boosty, Gumroad, DLsite, Discord) статус синхронизируется с сервером на лету.

### 🎬 Умный медиаплеер и определение разрешения
- **Ленивое вычисление габаритов (1920×1080 и др.)**: Определение точного разрешения картинок и видео без полной предварительной загрузки тяжелых файлов.
- **Автоповорот в полноэкранном режиме**: Видеоплеер автоматически ориентирует экран (альбомный или портретный режим) в зависимости от аспектного соотношения медиа.

### 📦 Разделение APK и умное автообновление по ABI
- Сборка облегчённых APK с разделением по архитектурам процессора (`arm64-v8a`, `armeabi-v7a`, `x86_64`).
- Встроенная система обновлений автоматически определяет архитектуру вашего Android-устройства и скачивает только нужный APK, экономя трафик и ускоряя загрузку.

---

## 📚 Документация и Вики (Руководство пользователя)

Подробные иллюстрированные руководства доступны в **[Lunaris Wiki](https://github.com/RarDog/Lunaris/wiki)** и прямо в репозитории:

- 🚀 **[Быстрый старт и установка](docs/wiki/Getting-Started.md)** — выбор правильного APK под процессор, запуск на Linux.
- 🌐 **[Провайдеры контента](docs/wiki/Providers.md)** — особенности Booru (Gelbooru, Rule34, Realbooru, e621) и архивов Pawchive.
- 🔍 **[Умный поиск и теги](docs/wiki/Search-and-Tags.md)** — оператор `and`, общие модификаторы и подсказки за 0 мс.
- 🐾 **[Интеграция с Pawchive](docs/wiki/Pawchive-Sync.md)** — вход по паролю/куки, двусторонняя синхронизация и выгрузка авторов.
- 🎬 **[Медиаплеер и просмотр](docs/wiki/Media-Viewer.md)** — жесты, автоповорот видео, разрешение 1920×1080 и Action Dock 2.0.
- 💾 **[Офлайн-режим и загрузки](docs/wiki/Offline-and-Downloads.md)** — Sync Hub, шаблоны папок и сохранение оригиналов.
- 🛡️ **[Черный список и фильтрация](docs/wiki/Safety-and-Blacklist.md)** — настройка Blacklist, Safe Mode и очистка кэша.
- ❓ **[Часто задаваемые вопросы (FAQ)](docs/wiki/FAQ.md)** — автообновление, звук в видео и решение проблем.

---

## ✨ Ключевые возможности

- **📱 Плавная лента в стиле Pinterest**: Masonry-сетка с переключением режима отображения (Masonry, 1:1 Сетка, Компактный список).
- **💾 Офлайн 2.0 и Sync Hub**: Просмотр фото и видео прямо из локального хранилища без запросов в сеть, аналитика занятого места и пакетная выгрузка.
- **🔍 Поиск 2.0 с операторами**: Быстрые подсказки тегов со скоростью отклика 0 мс, оператор `and` для мульти-поиска, фильтры `type:video`, `rating:safe`.
- **🛡️ Продвинутый Blacklist / Whitelist**: Фильтрация нежелательного контента по тегам, категориям, рейтингу и минимальному score.
- **📁 Умный менеджер загрузок**: Шаблоны поддиректорий (`{Artist}`, `{Provider}`, `{Service}`, `{ID}`, `{Date}`) для аккуратного архива.
- **🌑 AMOLED Pure Black**: Истинно черный фон для максимальной энергоэффективности на OLED/AMOLED дисплеях.

---

## 🌐 Поддерживаемые провайдеры

| Провайдер | Тип API | Поддерживаемый контент |
|---|---|---|
| **Pawchive** | REST API v1 | Patreon, Pixiv Fanbox, Fantia, Boosty, Gumroad, DLsite, Discord |
| **Gelbooru** | JSON / XML API | Аниме-арты, теги, авторы, рейтинги |
| **Rule34** | Booru API | Огромная база booru-контента, видео и GIF |
| **Realbooru** | Scraper / API | Фотосессии и реалистичный контент |
| **e621 / e926** | REST JSON API | Фурри- и антро-арт с богатейшей таксономией тегов |

---

## 📥 Загрузка (Скачать сборки)

Релизы доступны на странице **[GitHub Releases](https://github.com/RarDog/Lunaris/releases)**.

| Платформа | Архитектура | Формат | Описание |
|---|---|---|---|
| **Android** | `arm64-v8a` | `.apk` | Оптимизировано для современных смартфонов (64-bit) |
| **Android** | `armeabi-v7a` | `.apk` | Для более старых Android-устройств (32-bit) |
| **Android** | `x86_64` | `.apk` | Для эмуляторов Android и x86-планшетов |
| **Linux** | `x86_64` | `.tar.gz` | Портативный архив для Linux-дистрибутивов |
| **Windows** | `x64` | `.zip` / `.exe` | Портативная и установочная сборка для Windows 10/11 |

---

## 🛠️ Сборка из исходников

### Требования
- **Flutter SDK**: `>= 3.22.0` (Dart `>= 3.4.0`)
- **Android SDK**: Build-Tools & Platform-Tools (для Android)
- **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`
- **Windows**: Visual Studio 2022 с компонентом «Desktop development with C++»

### Быстрый старт

```bash
# Клонирование репозитория
git clone https://github.com/RarDog/Lunaris.git
cd Lunaris

# Установка зависимостей
flutter pub get

# Проверка анализатора и запуск тестов
flutter analyze
flutter test

# Запуск в режиме разработки
flutter run
```

### Сборка релизных пакетов

```bash
# Android (раздельные APK по архитектурам)
flutter build apk --release --split-per-abi

# Linux (Desktop bundle)
flutter build linux --release

# Windows (Desktop bundle)
flutter build windows --release
```

---

## 🏛️ Архитектура проекта

```text
lib/
 ├── app/               # Роутер (GoRouter), темы, локализация (RU/EN), анимации
 ├── backend/
 │    ├── di/           # Внедрение зависимостей (Riverpod providers)
 │    ├── models/       # Post, ArtistProfile, PawchiveAccount, AppSettings
 │    ├── providers/    # Клиенты API (Gelbooru, Rule34, Pawchive, e621)
 │    ├── repositories/ # Локальная база данных Isar и кэширование
 │    └── services/     # Сервисы: PawchiveSync, Feed, Search, Downloads, Updates
 ├── core/              # Сетевой клиент (Dio), база данных, утилиты
 ├── features/          # Модули экранов: feed, post, artists, favorites, settings
 └── shared/widgets/    # Переиспользуемые компоненты (PostCard, MasonryGrid, Dock)
```

---

## 🔒 Безопасность и конфиденциальность

- **100% локальное хранение**: Вся история, закладки, локальные авторы и конфигурации хранятся только в вашей локальной базе на устройстве.
- **Никакой телеметрии**: Lunaris не собирает аналитику, не отправляет логи и уважает вашу приватность.
- **Прямое соединение**: Запросы отправляются напрямую к выбранным API без прокси-серверов посредников.

---

## 👥 Разработчики

<p align="center">
  <strong>Разработчики:</strong> <a href="https://github.com/RarDog">RarDog</a> & <a href="https://deepmind.google/technologies/gemini/">Antigravity (Gemini)</a>
</p>

<p align="center">
  <a href="https://github.com/RarDog"><img src="https://img.shields.io/badge/Developer-RarDog-blue?style=for-the-badge&logo=github&logoColor=white" alt="RarDog" /></a>
  <a href="https://deepmind.google/technologies/gemini/"><img src="https://img.shields.io/badge/AI%20Pair-Antigravity%20(Gemini)-8A2BE2?style=for-the-badge&logo=google&logoColor=white" alt="Antigravity" /></a>
</p>
