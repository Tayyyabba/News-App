# Daily News - Flutter Internship Project 2

A complete Flutter news reader app implementing the internship requirements:

- NewsAPI integration using HTTP (Retrofit-equivalent API service structure)
- Article list using ListView.builder (Flutter equivalent of Android RecyclerView)
- Open full article in the external browser
- Category filters: Business, Sports, Technology, Science, Health, Entertainment
- Endless scrolling / pagination
- Local caching with SharedPreferences for offline viewing
- Pull-to-refresh
- Loading and error states
- Demo articles when no NewsAPI key is configured

## Run

1. Open this folder in VS Code.
2. Run `flutter pub get`.
3. Open `lib/services/news_api_service.dart`.
4. Replace `PASTE_YOUR_NEWSAPI_KEY_HERE` with your NewsAPI key.
5. Run `flutter run`.

If you do not add a key, the app will still run with demo articles so you can test the UI and scrolling. For your final internship submission, add a real API key and test live news.

## Important

The assignment mentions Retrofit + RecyclerView because it is written for native Android. In Flutter, the corresponding implementation is an HTTP API service + ListView.builder.
