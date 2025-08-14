import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/article.dart';
import '../../../../config/theme/app_themes.dart';
import '../pages/article_view/article_view.dart';

class ArticleTile extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback? onTap;
  final bool enableHero;

  const ArticleTile({
    Key? key,
    required this.article,
    this.onTap,
    this.enableHero = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180, // Altura fija para consistencia
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _navigateToArticleView(context),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del artículo
                _buildArticleImage(context),
                const SizedBox(width: 16),
                // Contenido del artículo
                Expanded(
                  child: _buildArticleContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage(BuildContext context) {
    final imageWidget = article.urlToImage != null && article.urlToImage!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: article.urlToImage!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Skeletonizer(
              enabled: true,
              child: Container(
                color: Colors.grey[300],
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 50,
              ),
            ),
          )
        : Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.article,
              color: Colors.grey,
              size: 50,
            ),
          );

    return SizedBox(
      width: 130,
      height: 150,
      child: enableHero && article.urlToImage != null && article.urlToImage!.isNotEmpty
          ? Hero(
              tag: 'article_image_${article.id ?? article.title ?? article.urlToImage}',
              child: imageWidget,
            )
          : imageWidget,
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título del artículo
        if (article.title != null && article.title!.isNotEmpty)
          Text(
            article.title!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Merriweather',
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 8),
        
        // Descripción del artículo
        if (article.description != null && article.description!.isNotEmpty)
          Text(
            article.description!,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Merriweather',
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        
        const Spacer(),
        
        // Tiempo de lectura y autor en la parte inferior
        _buildBottomInfo(),
      ],
    );
  }

  Widget _buildBottomInfo() {
    final content = (article.content ?? article.description ?? '');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.newspaper,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            // Sección del source - ocupa exactamente el 70% del espacio disponible
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
                      '${article.lectureTime ?? _calculateReadingTime(content)} min',
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
        
          
        
      ],
    );
  }

  int _calculateReadingTime(String content) {
    if (content.isEmpty) return 1;
    
    const int wordsPerMinute = 225;
    final words = _countWords(content);
    final readingTime = (words / wordsPerMinute).ceil();
    
    return readingTime < 1 ? 1 : readingTime;
  }
  
  int _countWords(String text) {
    if (text.isEmpty) return 0;
    
    // Extraer caracteres adicionales del formato [+XXXX chars] si existe
    int additionalChars = _extractAdditionalChars(text);
    
    // Limpiar el texto removiendo el patrón [+XXXX chars] si existe
    String cleanedText = text.replaceAll(RegExp(r'\s*…\s*\[\+\d+\s+chars\]$'), '');
    
    // Limpiar el texto y dividir por espacios en blanco
    final processedText = cleanedText
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Reemplazar puntuación con espacios
        .replaceAll(RegExp(r'\s+'), ' ') // Normalizar espacios múltiples
        .trim();
    
    if (processedText.isEmpty && additionalChars == 0) return 0;
    
    // Contar palabras del texto visible
    int visibleWords = processedText.isEmpty ? 0 : processedText.split(' ').length;
    
    // Convertir caracteres adicionales a palabras aproximadas (promedio 5 caracteres por palabra)
    int additionalWords = (additionalChars / 5).round();
    
    return visibleWords + additionalWords;
  }
  
  int _extractAdditionalChars(String text) {
    // Buscar el patrón [+XXXX chars] al final del texto
    final match = RegExp(r'\[\+(\d+)\s+chars\]$').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  void _navigateToArticleView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleViewPage(article: article),
      ),
    );
  }
}
