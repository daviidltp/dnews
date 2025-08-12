import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/article.dart';
import '../../../../config/theme/app_themes.dart';

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
    final imageHeight = screenHeight * 0.53; // Imagen más alta, basada en la altura de la pantalla
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen sin contenedor compartido
            ClipRRect(
              child: Stack(
                children: [
                  _buildImage(imageHeight),
                  // Ícono de bookmark abajo-derecha
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        color: AppColors.secondary,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenido del artículo completamente separado, sin fondo
            const SizedBox(height: 16),
            _buildArticleContent(),

          ],
        ),
      ),
    );
  }

  Widget _buildImage(double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: article.urlToImage != null && article.urlToImage!.isNotEmpty
          ? CachedNetworkImage(
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
            )
          : Container(
              color: AppColors.surface,
              child: const Icon(
                Icons.article,
                color: AppColors.textTertiary,
                size: 80,
              ),
            ),
    );
  }

  Widget _buildArticleContent() {
    return Padding(
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
                fontFamily: 'Times New Roman',
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
                      const Icon(
                        Icons.newspaper,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          article.source ?? 'No Source',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
    );
  }
}
