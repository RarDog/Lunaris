# 🌙 Lunaris

<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="128" height="128" alt="Lunaris Logo" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.35);" />
</p>

<p align="center">
  <strong>Современный кроссплатформенный клиент для Booru и Creator-архивов нового поколения</strong><br>
  Плавный Pinterest-стиль, интеграция Pawchive 2.0, двусторонняя синхронизация, интеллектуальное автообновление и воспроизведение медиа без задержек.
</p>

<p align="center">
  <a href="https://github.com/RarDog/Lunaris/releases"><img src="https://img.shields.io/badge/Version-3.0.0-8A2BE2?style=for-the-badge&logo=semver&logoColor=white" alt="Version 3.0.0" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.47+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Linux%20%7C%20Windows-00C853?style=for-the-badge" alt="Platforms" />
  <a href="https://gitea.rardogsynapse.online/RarDog/Lunaris"><img src="https://img.shields.io/badge/Gitea-RarDog%2FLunaris-FC6D26?style=for-the-badge&logo=gitea&logoColor=white" alt="Gitea" /></a>
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

Релизы доступны на **[GitHub Releases](https://github.com/RarDog/Lunaris/releases)** и в личном репозитории **[Gitea Releases](https://gitea.rardogsynapse.online/RarDog/Lunaris/releases)**.

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

<p align="center">
  Разработано с ❤️ командой Lunaris.
</p>
