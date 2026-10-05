import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class CacheService {
  static const String _key = 'cached_articles';

  Future<void> saveArticles(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final data = articles.map((a) => a.toJson()).toList();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<List<Article>> loadArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Article.fromCache)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
