import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/featured_article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

class SkeletonFeaturedArticleTile extends StatelessWidget {
  final int? uniqueId;
  
  const SkeletonFeaturedArticleTile({Key? key, this.uniqueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Crear artículo dummy para el skeleton con ID único
    final dummyArticle = ArticleEntity(
      id: uniqueId ?? DateTime.now().millisecondsSinceEpoch,
      title: 'Este es un título de ejemplo para el artículo destacado que puede ser bastante largo',
      description: 'Esta es una descripción de ejemplo que simula el contenido del artículo destacado.',
      urlToImage: 'https://image.cnbcfm.com/api/v1/image/108167827-1751570380167-250730-cn-16-np-LightSpray-RC00_02_20_05Still009.png?v=1751570507&w=1920&h=1080',
      source: 'DNews',
      publishedAt: DateTime.now().toIso8601String(),
      content: 'Contenido de ejemplo para el artículo.',
      lectureTime: 5,
    );

    return Skeletonizer(
      enabled: true,
      child: FeaturedArticleTile(article: dummyArticle),
    );
  }
}

class SkeletonArticleTile extends StatelessWidget {
  final int? uniqueId;
  final bool enableHero;
  
  const SkeletonArticleTile({Key? key, this.uniqueId, this.enableHero = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Crear artículo dummy para el skeleton con ID único
    final dummyArticle = ArticleEntity(
      id: uniqueId ?? DateTime.now().millisecondsSinceEpoch,
      title: 'Este es un título de ejemplo para el artículo que puede tener múltiples líneas',
      description: 'Esta es una descripción de ejemplo que simula el contenido del artículo normal con texto de relleno.',
      urlToImage: 'https://image.cnbcfm.com/api/v1/image/108167827-1751570380167-250730-cn-16-np-LightSpray-RC00_02_20_05Still009.png?v=1751570507&w=1920&h=1080',
      source: 'Fuente Externa',
      publishedAt: DateTime.now().toIso8601String(),
      content: 'Contenido de ejemplo para el artículo.',
      lectureTime: 3,
    );

    return Skeletonizer(
      enabled: true,
      child: ArticleTile(article: dummyArticle, enableHero: enableHero),
    );
  }
}
