import 'package:equatable/equatable.dart';

enum ArticleCategory {
  general,
  business,
  science,
  sports,
  technology,
  dnews, // Categoría específica para noticias de Firebase
}

extension ArticleCategoryExtension on ArticleCategory {
  String get displayName {
    switch (this) {
      case ArticleCategory.general:
        return 'General';
      case ArticleCategory.business:
        return 'Business';
      case ArticleCategory.science:
        return 'Science';
      case ArticleCategory.sports:
        return 'Sports';
      case ArticleCategory.technology:
        return 'Technology';
      case ArticleCategory.dnews:
        return 'DNews';
    }
  }

  String get apiValue {
    switch (this) {
      case ArticleCategory.general:
        return 'general';
      case ArticleCategory.business:
        return 'business';
      case ArticleCategory.science:
        return 'science';
      case ArticleCategory.sports:
        return 'sports';
      case ArticleCategory.technology:
        return 'technology';
      case ArticleCategory.dnews:
        return 'dnews'; // No se usa para API, solo para Firebase
    }
  }

  static ArticleCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'general':
        return ArticleCategory.general;
      case 'business':
        return ArticleCategory.business;
      case 'science':
        return ArticleCategory.science;
      case 'sports':
        return ArticleCategory.sports;
      case 'technology':
        return ArticleCategory.technology;
      case 'dnews':
        return ArticleCategory.dnews;
      default:
        return ArticleCategory.general;
    }
  }
}

class ArticleEntity extends Equatable {
  final int ? id;
  final String ? author;
  final String ? title;
  final String ? description;
  final String ? url;
  final String ? urlToImage;
  final String ? publishedAt;
  final String ? content;
  final String ? source;
  final int ? lectureTime; // Tiempo de lectura en minutos
  final ArticleCategory category; // Propiedad para categoría

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.source,
    this.lectureTime,
    this.category = ArticleCategory.general, // Valor por defecto
  });

  @override
  List<Object?> get props => [id, author, title, description, url, urlToImage, publishedAt, content, source, lectureTime, category];
}