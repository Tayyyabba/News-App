class Article {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final DateTime? publishedAt;
  final String author;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final sourceData = json['source'];
    return Article(
      title: (json['title'] ?? 'No title available').toString(),
      description: (json['description'] ?? 'No description available.').toString(),
      url: (json['url'] ?? '').toString(),
      imageUrl: (json['urlToImage'] ?? '').toString(),
      source: sourceData is Map ? (sourceData['name'] ?? 'Unknown source').toString() : 'Unknown source',
      publishedAt: DateTime.tryParse((json['publishedAt'] ?? '').toString()),
      author: (json['author'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt?.toIso8601String(),
      'author': author,
    };
  }

  factory Article.fromCache(Map<String, dynamic> json) {
    return Article(
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      publishedAt: DateTime.tryParse((json['publishedAt'] ?? '').toString()),
      author: (json['author'] ?? '').toString(),
    );
  }
}
