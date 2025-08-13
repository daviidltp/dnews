import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

class ArticleViewPage extends StatelessWidget {
  final ArticleEntity article;

  const ArticleViewPage({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            _buildCustomAppBar(context),
            // Scrollable article content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article image
                    _buildArticleImage(),
                    // Article content
                    _buildArticleContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Artículo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    if (article.urlToImage == null || article.urlToImage!.isEmpty) {
      return Container(
        height: 350,
        width: double.infinity,
        color: AppColors.surface,
        child: const Icon(
          Icons.article,
          color: AppColors.textTertiary,
          size: 80,
        ),
      );
    }

    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Hero(
        tag: 'article_image_${article.id ?? article.title ?? article.urlToImage}',
        child: CachedNetworkImage(
          imageUrl: article.urlToImage!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.surface,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.surface,
            child: const Icon(
              Icons.image_not_supported,
              color: AppColors.textTertiary,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (article.title != null && article.title!.isNotEmpty)
            Text(
              article.title!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Merriweather',
                height: 1.2,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Description
          if (article.description != null && article.description!.isNotEmpty)
            Text(
              article.description!,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontFamily: 'Merriweather',
                height: 1.2,
              ),
            ),
          
          const SizedBox(height: 8),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          
          const SizedBox(height: 4),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.newspaper,
                      color: article.source == 'DNews' ? AppColors.accent : AppColors.textSecondary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        article.source ?? 'Anónimo',
                        style: TextStyle(
                          color:  article.source == 'DNews' ? AppColors.accent : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        'By ${article.author ?? 'Anónimo'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      '${article.lectureTime} min read',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Author and reading time info
         
          
          const SizedBox(height: 24),
          
          // Content
          if (article.content != null && article.content!.isNotEmpty)
            MarkdownBody(
              data: article.content!,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Merriweather',
                  height: 1.6,
                ),
                h1: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                  height: 1.3,
                ),
                h2: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                  height: 1.3,
                ),
                h3: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                  height: 1.3,
                ),
                strong: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                ),
                em: const TextStyle(
                  color: AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Merriweather',
                ),
                code: TextStyle(
                  backgroundColor: AppColors.surface,
                  color: AppColors.textPrimary,
                  fontFamily: 'Merriweather',
                  fontSize: 14,
                ),
                codeblockDecoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                blockquote: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Merriweather',
                ),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.textPrimary.withOpacity(0.3),
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
