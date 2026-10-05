import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                height: 220,
                child: article.imageUrl.isEmpty
                    ? Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.newspaper_rounded, size: 70),
                      )
                    : Image.network(
                        article.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image_not_supported_outlined, size: 60),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Text(article.source, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(article.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (article.author.isNotEmpty) Text('By ${article.author}', style: const TextStyle(fontWeight: FontWeight.w600)),
            if (article.publishedAt != null) ...[
              const SizedBox(height: 5),
              Text('Published: ${article.publishedAt!.day}/${article.publishedAt!.month}/${article.publishedAt!.year}'),
            ],
            const SizedBox(height: 18),
            Text(article.description, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openArticle(context),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Read Full Article'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
