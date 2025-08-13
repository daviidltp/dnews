import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

class ArticleModel extends ArticleEntity {
  const ArticleModel({
    super.id,
    super.author,
    super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
    super.source,
    super.lectureTime,
    super.category,
    super.saved,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json, [ArticleCategory? category]) {
    return ArticleModel(
      author: json['author'] ?? 'Anonymous',
      title: _cleanTitle(json['title'] ?? ''),
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'] ?? '',
      source: json['source']['name'] ?? '',
      lectureTime: 0, // Se calculará después en el repositorio
      category: category ?? ArticleCategory.general,
      saved: false, // Los artículos de API no están guardados por defecto
    );
  }

  // Método para limpiar el título eliminando el sufijo del periódico
  static String _cleanTitle(String title) {
    if (title.isEmpty) return title;
    
    // Buscar el patrón " - {periódico}" al final del título
    final RegExp pattern = RegExp(r'\s*-\s*[^-]+$');
    
    return title.replaceFirst(pattern, '').trim();
  }

  factory ArticleModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ArticleModel(
      id: _parseToInt(data['id']) ?? 0,
      author: data['author']?.toString() ?? 'Anonymous',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      url: data['url']?.toString() ?? '',
      urlToImage: data['urlToImage']?.toString() ?? data['thumbnailURL']?.toString() ?? '',
      publishedAt: data['publishedAt']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      source: data['source']?.toString() ?? '',
      lectureTime: _parseToInt(data['lectureTime']) ?? 0,
      category: ArticleCategory.dnews, // Los artículos de Firebase siempre son DNews
      saved: data['saved'] == true, // Lee el estado guardado desde Firebase
    );
  }

  // Método auxiliar para convertir cualquier tipo a int de forma segura
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
      source: source,
      lectureTime: lectureTime,
      category: category,
      saved: saved,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'source': source,
      'lectureTime': lectureTime,
      'category': category.apiValue,
      'saved': saved,
    };
  }
}