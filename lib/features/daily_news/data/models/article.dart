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
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'] ?? '',
      source: json['source']['name'] ?? '',
    );
  }

  factory ArticleModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ArticleModel(
      id: _parseToInt(data['id']) ?? 0,
      author: data['author']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      url: data['url']?.toString() ?? '',
      urlToImage: data['thumbnailURL']?.toString() ?? '',
      publishedAt: data['publishedAt']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      source: data['source']?.toString() ?? '',
      lectureTime: _parseToInt(data['lectureTime']) ?? 0,
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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'thumbnailURL': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'source': source,
      'lectureTime': lectureTime,
    };
  }
}