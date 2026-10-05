import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/cache_service.dart';
import '../services/news_api_service.dart';
import '../widgets/article_card.dart';
import 'article_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsApiService _api = NewsApiService();
  final CacheService _cache = CacheService();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> categories = const [
    {'name': 'All', 'value': 'general', 'icon': '📰'},
    {'name': 'Business', 'value': 'business', 'icon': '💼'},
    {'name': 'Sports', 'value': 'sports', 'icon': '⚽'},
    {'name': 'Technology', 'value': 'technology', 'icon': '💻'},
    {'name': 'Science', 'value': 'science', 'icon': '🔬'},
    {'name': 'Health', 'value': 'health', 'icon': '❤️'},
    {'name': 'Entertainment', 'value': 'entertainment', 'icon': '🎬'},
  ];

  List<Article> articles = [];
  String selectedCategory = 'general';
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;
  String? error;
  int page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !loadingMore && !loading && hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadNews({bool refresh = false}) async {
    if (loading) return;
    setState(() {
      loading = true;
      error = null;
      if (refresh) {
        page = 1;
        articles = [];
        hasMore = true;
      }
    });

    try {
      final result = await _api.fetchNews(category: selectedCategory, page: 1);
      if (!mounted) return;
      setState(() {
        articles = result;
        page = 1;
        hasMore = result.isNotEmpty;
      });
      if (result.isNotEmpty) await _cache.saveArticles(result);
    } catch (e) {
      final cached = await _cache.loadArticles();
      if (!mounted) return;
      setState(() {
        articles = cached;
        error = cached.isEmpty ? 'Could not load news. Check your internet connection.' : 'Showing your cached news.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => loadingMore = true);
    try {
      final nextPage = page + 1;
      final result = await _api.fetchNews(category: selectedCategory, page: nextPage);
      if (!mounted) return;
      setState(() {
        articles.addAll(result);
        page = nextPage;
        hasMore = result.isNotEmpty;
      });
    } catch (_) {
      if (mounted) setState(() => hasMore = false);
    } finally {
      if (mounted) setState(() => loadingMore = false);
    }
  }

  Future<void> _selectCategory(String category) async {
    if (category == selectedCategory) return;
    setState(() => selectedCategory = category);
    await _loadNews(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.newspaper_rounded),
            SizedBox(width: 9),
            Text('Daily News', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(onPressed: () => _loadNews(refresh: true), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final item = categories[index];
                final selected = item['value'] == selectedCategory;
                return ChoiceChip(
                  selected: selected,
                  label: Text('${item['icon']} ${item['name']}'),
                  onSelected: (_) => _selectCategory(item['value']!),
                );
              },
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.errorContainer,
                ),
                child: Text(error!),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadNews(refresh: true),
              child: loading && articles.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : articles.isEmpty
                      ? ListView(children: const [SizedBox(height: 180), Center(child: Text('No news found.'))])
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 20),
                          itemCount: articles.length + (loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == articles.length) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final article = articles[index];
                            return ArticleCard(
                              article: article,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ArticleScreen(article: article)),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
