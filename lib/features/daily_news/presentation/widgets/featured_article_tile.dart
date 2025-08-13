import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/article.dart';
import '../../../../config/theme/app_themes.dart';
import '../pages/article_view/article_view.dart';

class FeaturedArticleTile extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback? onTap;

  const FeaturedArticleTile({
    Key? key,
    required this.article,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.5; // Imagen más alta, basada en la altura de la pantalla
    
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _navigateToArticleView(context),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen sin contenedor compartido
               _buildImage(imageHeight),
              // Contenido del artículo completamente separado, sin fondo
              const SizedBox(height: 8),
              _buildArticleContent(),

            ],
          ),
        ),
      ),
    );
  }

    Widget _buildImage(double height) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: article.urlToImage != null && article.urlToImage!.isNotEmpty
            ? Hero(
                tag: 'article_image_${article.id ?? article.title ?? article.urlToImage}',
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Skeletonizer(
                    enabled: true,
                    child: Container(
                      color: AppColors.surface,
                      width: double.infinity,
                      height: double.infinity,
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
              )
            : Container(
                color: AppColors.surface,
                child: const Icon(
                  Icons.article,
                  color: AppColors.textTertiary,
                  size: 80,
                ),
              ),
      ),
    );
  }

  Widget _buildArticleContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4), // Solo un padding mínimo lateral
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del artículo
            if (article.title != null && article.title!.isNotEmpty)
              Text(
                article.title!,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Merriweather',
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: 12),
            
            // Información del autor y tiempo de lectura
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  // Sección del source - ocupa exactamente el 70% del espacio disponible
                  Expanded(
                    flex: 7,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Icon(
                          Icons.newspaper,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 7,
                          child: article.source == 'DNews'
                            ? RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'D',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'News',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                article.source ?? 'Anónimo',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8), // Pequeño espaciado entre las dos secciones
                  // Sección del tiempo de lectura - ocupa exactamente el 30% del espacio disponible
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${article.lectureTime} min read',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToArticleView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleViewPage(article: article),
      ),
    );
  }
}
