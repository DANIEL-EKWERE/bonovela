class AppConstants {
  static const String appName = 'Bonovela';

  /// Horizontal wordmark (icon + "Bonovela"), on white.
  static const String logoAsset = 'assets/images/logo_wordmark.png';

  /// Square app-icon artwork.
  static const String iconAsset = 'assets/images/app_icon.png';

  /// Backend base URL, e.g. `--dart-define=API_URL=https://api.bonovela.app`.
  /// Empty runs the app on built-in sample data.
  static const String apiUrl = String.fromEnvironment('API_URL');

  // Genre tabs used by Discover, Rank and Categories.
  static const List<String> genres = ['Werewolf', 'Romance', 'Mafia', 'Fantasy', 'LGBTQ+'];

  // Author rules; the backend enforces the same numbers (settings.BONOVELA).
  static const int synopsisMinWords = 50;
  static const int synopsisMaxWords = 300;
  static const int chapterMinWords = 600;
  static const int chapterMaxWords = 2000;
  static const int contractMinWords = 5000; // published words before Apply for Contract

  // Monetisation (mock).
  static const int freeChapters = 10;
  static const int chapterPrice = 15;
  static const String currency = '\$';

  // Drama episodes: the first few are free, then coins per episode
  // (free for Plus members).
  static const int freeEpisodes = 5;
  static const int episodePrice = 10;
}
