class AppStrings {
  const AppStrings(this.languageCode);

  final String languageCode;
  bool get ru => languageCode == 'ru';

  String get feed => ru ? 'Лента' : 'Feed';
  String get search => ru ? 'Поиск' : 'Search';
  String get favorites => ru ? 'Избранное' : 'Favorites';
  String get viewed => ru ? 'История' : 'Viewed';
  String get collections => ru ? 'Коллекции' : 'Collections';
  String get boardsShort => ru ? 'Доски' : 'Boards';
  String get artists => ru ? 'Артисты' : 'Artists';
  String get providers => ru ? 'Провайдеры' : 'Providers';
  String get settings => ru ? 'Настройки' : 'Settings';
  String get post => ru ? 'Пост' : 'Post';
  String get close => ru ? 'Закрыть' : 'Close';
  String get retry => ru ? 'Повторить' : 'Retry';
  String get tags => ru ? 'Теги' : 'Tags';
  String get comments => ru ? 'Комментарии' : 'Comments';
  String get commentsUnavailable =>
      ru ? 'Комментарии недоступны' : 'Comments unavailable';
  String get noComments => ru ? 'Комментариев нет' : 'No comments';
  String get anonymous => ru ? 'Аноним' : 'Anonymous';
  String get source => ru ? 'Источник' : 'Source';
  String get similar => ru ? 'Похожие' : 'Similar';
  String get favorite => ru ? 'В избранное' : 'Favorite';
  String get removeFavorite => ru ? 'Убрать из избранного' : 'Remove favorite';
  String get collection => ru ? 'Коллекция' : 'Collection';
  String get addToCollection =>
      ru ? 'Добавить в коллекцию' : 'Add to collection';
  String get download => ru ? 'Скачать' : 'Download';
  String get deleteLocalFile =>
      ru ? 'Удалить локальный файл' : 'Delete local file';
  String get downloaded => ru ? 'Скачано' : 'Downloaded';
  String get downloading => ru ? 'Скачивается' : 'Downloading';
  String get failed => ru ? 'Ошибка' : 'Failed';
  String get open => ru ? 'Открыть' : 'Open';
  String get hidePost => ru ? 'Скрыть пост' : 'Hide post';
  String get hiddenLocally =>
      ru ? 'Пост скрыт локально' : 'Post hidden locally';
  String get undo => ru ? 'Отменить' : 'Undo';
  String get noPostsYet => ru ? 'Постов пока нет' : 'No posts yet';
  String get tryAnotherTag => ru
      ? 'Попробуй другой тег или проверь провайдеры.'
      : 'Try another tag or check providers.';
  String get searchTags => ru ? 'Поиск тегов' : 'Search tags';
  String get selected => ru ? 'выбрано' : 'selected';
  String get createCollection => ru ? 'Создать коллекцию' : 'Create collection';
  String get noFavorites => ru ? 'Избранного пока нет' : 'No favorites yet';
  String get general => ru ? 'Основное' : 'General';
  String get appearance => ru ? 'Внешний вид' : 'Appearance';
  String get feedLayout => ru ? 'Лента и раскладка' : 'Feed & Layout';
  String get filters => ru ? 'Фильтры' : 'Filters';
  String get storage => ru ? 'Хранилище' : 'Storage';
  String get about => ru ? 'О приложении' : 'About';
  String get theme => ru ? 'Тема' : 'Theme';
  String get language => ru ? 'Язык' : 'Language';
  String get allowNsfw => ru ? 'Показывать NSFW' : 'Allow NSFW content';
  String get blurSensitive =>
      ru ? 'Размывать чувствительные превью' : 'Blur sensitive previews';
  String get showPostBadges =>
      ru ? 'Показывать подписи на карточках' : 'Show post badges';
  String get allowDownloads =>
      ru ? 'Разрешить ручные скачивания' : 'Allow manual downloads';
  String get autoDownloadFavorites => ru
      ? 'Автоскачивание при добавлении в избранное'
      : 'Auto-download new favorites';
  String get autoDownloadFavoritesHint => ru
      ? 'Избранное добавляется сразу, а файл качается в фоне.'
      : 'The favorite is saved immediately while the file downloads in the background.';
  String get mediaQuality => ru ? 'Качество медиа' : 'Media quality';
  String get desktopColumns => ru ? 'Колонки на ПК' : 'Desktop columns';
  String get mobileColumns => ru ? 'Колонки на телефоне' : 'Mobile columns';
  String get hideViewed => ru ? 'Скрывать просмотренное' : 'Hide viewed posts';
  String get smartBlacklist => ru ? 'Умный blacklist' : 'Smart blacklist';
  String get whitelistedTags => ru ? 'Whitelist тегов' : 'Whitelisted tags';
  String get cacheMaxItems => ru ? 'Лимит кеша' : 'Cache max items';
  String get clearCache => ru ? 'Очистить кеш' : 'Clear cache';
  String get clearViewed => ru ? 'Очистить историю' : 'Clear viewed history';
  String get exportJson => ru ? 'Экспорт JSON' : 'Export JSON';
  String get importJson => ru ? 'Импорт JSON' : 'Import JSON';
  String get checkUpdates => ru ? 'Проверить обновления' : 'Check updates';
  String get appUpdateAvailable =>
      ru ? 'Доступно обновление' : 'Update available';
  String get skipThisVersion => ru ? 'Пропустить версию' : 'Skip this version';
  String get later => ru ? 'Позже' : 'Later';
  String get downloadAndOpen => ru ? 'Скачать и открыть' : 'Download & open';
  String get couldNotLoadImage =>
      ru ? 'Не удалось загрузить изображение' : 'Could not load image';
  String get couldNotLoadVideo =>
      ru ? 'Не удалось загрузить видео' : 'Could not load video';
  String get play => ru ? 'Воспроизвести' : 'Play';
  String get pause => ru ? 'Пауза' : 'Pause';
  String get mute => ru ? 'Выключить звук' : 'Mute';
  String get unmute => ru ? 'Включить звук' : 'Unmute';
  String get repeatVideo => ru ? 'Повторять видео' : 'Repeat video';
  String get disableRepeat => ru ? 'Отключить повтор' : 'Disable repeat';
  String get fullscreen => ru ? 'На весь экран' : 'Fullscreen';
  String get exitFullscreen =>
      ru ? 'Выйти из полноэкранного режима' : 'Exit fullscreen';
}
