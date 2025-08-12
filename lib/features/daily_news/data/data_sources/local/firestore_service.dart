import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:symmetry_showcase/features/daily_news/data/models/article.dart';

abstract class FirestoreService {
  Future<List<ArticleModel>> getArticles();
  Future<void> saveArticle(ArticleModel article);
  Future<void> saveArticles(List<ArticleModel> articles);
}

class FirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;
  static const String _articlesCollection = 'articles';

  FirestoreServiceImpl(this._firestore);

  @override
  Future<List<ArticleModel>> getArticles() async {
    try {
      final querySnapshot = await _firestore
          .collection(_articlesCollection)
          .orderBy('publishedAt', descending: true)
          .get();

      final articles = <ArticleModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          final article = ArticleModel.fromFirestore(doc);
          articles.add(article);
        } catch (e) {
          print('Error parsing article from document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
          // Continuar con el siguiente documento en caso de error
        }
      }
      
      return articles;
    } catch (e) {
      throw Exception('Error al obtener artículos de Firestore: $e');
    }
  }

  @override
  Future<void> saveArticle(ArticleModel article) async {
    try {
      await _firestore
          .collection(_articlesCollection)
          .add(article.toFirestore());
    } catch (e) {
      throw Exception('Error al guardar artículo en Firestore: $e');
    }
  }

  @override
  Future<void> saveArticles(List<ArticleModel> articles) async {
    try {
      final batch = _firestore.batch();
      
      for (final article in articles) {
        final docRef = _firestore.collection(_articlesCollection).doc();
        batch.set(docRef, article.toFirestore());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Error al guardar artículos en Firestore: $e');
    }
  }
}
