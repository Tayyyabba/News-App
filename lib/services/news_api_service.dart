import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsApiService {
  // Get your free key from https://newsapi.org/ and paste it here.
  // The app still opens with demo articles if the key is empty/invalid.
  static const String apiKey = '62ac6d366e8148c49c36aecba571a88b';
  static const String baseUrl = 'https://newsapi.org/v2/top-headlines';

  Future<List<Article>> fetchNews({
    String category = 'general',
    int page = 1,
    int pageSize = 10,
  }) async {
    if (apiKey.isEmpty || apiKey.contains('PASTE_YOUR')) {
      await Future.delayed(const Duration(milliseconds: 500));
      return demoArticles(category, page);
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'country': 'us',
      'category': category,
      'page': '$page',
      'pageSize': '$pageSize',
      'apiKey': apiKey,
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('News service returned ${response.statusCode}.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'ok') {
      throw Exception((data['message'] ?? 'Unable to load news.').toString());
    }

    final articles = (data['articles'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Article.fromJson)
        .where((article) => article.title.isNotEmpty && article.title != '[Removed]')
        .toList();

    return articles;
  }

  List<Article> demoArticles(String category, int page) {
    final names = <String, List<String>>{
      'general': ['Global News Update', 'Today’s Top Stories', 'Latest Headlines'],
      'business': ['Markets and Business', 'Business Today', 'Company News'],
      'sports': ['Sports Highlights', 'Latest Sports News', 'Matchday Update'],
      'technology': ['Technology Update', 'New Tech Trends', 'Digital World'],
      'science': ['Science Today', 'New Research Update', 'Science & Discovery'],
      'health': ['Health News', 'Wellness Update', 'Medical World'],
      'entertainment': ['Entertainment Today', 'Celebrity & Culture', 'Movies and TV'],
    };
    final titles = names[category] ?? names['general']!;

    return List.generate(10, (index) {
      final number = ((page - 1) * 10) + index + 1;
      return Article(
        title: '${titles[index % titles.length]} — Story $number',
        description: 'This is a sample news article. Add your NewsAPI key in news_api_service.dart to load live headlines.',
        url: 'https://newsapi.org/',
        imageUrl: '',
        source: 'Demo News',
        publishedAt: DateTime.now().subtract(Duration(hours: index + page)),
        author: 'News App',
      );
    });
  }
}
