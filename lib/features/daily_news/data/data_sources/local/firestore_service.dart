import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:symmetry_showcase/features/daily_news/data/models/article.dart';

abstract class FirestoreService {
  Future<List<ArticleModel>> getArticles();
  Future<void> saveArticle(ArticleModel article);
  Future<void> saveArticles(List<ArticleModel> articles);
  
  // Métodos específicos para artículos guardados
  Future<List<ArticleModel>> getSavedArticles();
  Future<void> saveArticleAsBookmark(ArticleModel article);
  Future<void> removeSavedArticle(ArticleModel article);
  Future<void> updateArticleSavedStatus(ArticleModel article, bool saved);
  Future<bool> isArticleSaved(ArticleModel article);
}

class FirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;
  static const String _articlesCollection = 'articles';
  static const String _bookmarksCollection = 'bookmarks';
  
  // Caché en memoria para URLs de bookmarks
  final Set<String> _bookmarkedUrls = {};
  bool _cacheInitialized = false;

  FirestoreServiceImpl(this._firestore);

  // Método para inicializar el caché de bookmarks
  Future<void> _initializeBookmarksCache() async {
    if (_cacheInitialized) return;
    
    try {

      final bookmarksSnapshot = await _firestore
          .collection(_bookmarksCollection)
          .get();
      
      _bookmarkedUrls.clear();
      for (final doc in bookmarksSnapshot.docs) {
        final data = doc.data();
        final url = data['url'] as String?;
        if (url != null) {
          _bookmarkedUrls.add(url);
        }
      }
      
      _cacheInitialized = true;
    } catch (e) {

    }
  }

  @override
  Future<List<ArticleModel>> getArticles() async {
    try {
      // Obtener solo los artículos originales (no bookmarks guardados aquí)
      final querySnapshot = await _firestore
          .collection(_articlesCollection)
          .orderBy('publishedAt', descending: true)
          .get();

      final articles = <ArticleModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          
          final article = ArticleModel.fromFirestore(doc);
          articles.add(article);
        } catch (e) {

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
      final articleData = article.toFirestore();
      
      await _firestore
          .collection(_articlesCollection)
          .add(articleData);
          

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

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    try {
      final articles = <ArticleModel>[];
      
      // Obtener artículos DNews guardados
      final dNewsQuerySnapshot = await _firestore
          .collection(_articlesCollection)
          .where('saved', isEqualTo: true)
          .get();

      for (final doc in dNewsQuerySnapshot.docs) {
        try {
          final article = ArticleModel.fromFirestore(doc);
          articles.add(article);
        } catch (e) {

        }
      }
      
      // Obtener bookmarks (artículos de API guardados)
      final bookmarksQuerySnapshot = await _firestore
          .collection(_bookmarksCollection)
          .get();

      for (final doc in bookmarksQuerySnapshot.docs) {
        try {
          final article = ArticleModel.fromFirestore(doc);
          articles.add(article);
        } catch (e) {

        }
      }
      
      // Ordenar por fecha de publicación
      articles.sort((a, b) {
        if (a.publishedAt == null || b.publishedAt == null) return 0;
        return b.publishedAt!.compareTo(a.publishedAt!);
      });
      
      return articles;
    } catch (e) {
      throw Exception('Error al obtener artículos guardados de Firestore: $e');
    }
  }

  @override
  Future<void> saveArticleAsBookmark(ArticleModel article) async {
    try {

      
      // Verificar si ya existe un bookmark con esa URL
      final existingBookmark = await _firestore
          .collection(_bookmarksCollection)
          .where('url', isEqualTo: article.url)
          .limit(1)
          .get();
      
      if (existingBookmark.docs.isNotEmpty) {
        return; // Ya existe, no crear duplicado
      }
      
      // Crear una copia del artículo marcado como guardado
      final articleData = article.toFirestore();
      articleData['saved'] = true;
      
      // Generar un ID único para el artículo guardado
      final uniqueId = '${article.url?.hashCode ?? DateTime.now().millisecondsSinceEpoch}';
      articleData['id'] = uniqueId.hashCode;
      

      
      await _firestore
          .collection(_bookmarksCollection) // Guardar en colección de bookmarks
          .add(articleData);
      
      // Actualizar caché
      if (article.url != null) {
        _bookmarkedUrls.add(article.url!);
      }
          

    } catch (e) {

      throw Exception('Error al guardar artículo como bookmark en Firestore: $e');
    }
  }

  @override
  Future<void> removeSavedArticle(ArticleModel article) async {
    try {

      bool found = false;
      
      // 1. Buscar en bookmarks primero (artículos de API guardados)
      QuerySnapshot bookmarksQuerySnapshot;
      
      if (article.url != null && article.url!.isNotEmpty) {
        bookmarksQuerySnapshot = await _firestore
            .collection(_bookmarksCollection)
            .where('url', isEqualTo: article.url)
            .get();
      } else {
        bookmarksQuerySnapshot = await _firestore
            .collection(_bookmarksCollection)
            .where('id', isEqualTo: article.id)
            .get();
      }

      if (bookmarksQuerySnapshot.docs.isNotEmpty) {
        // Eliminar de bookmarks
        for (final doc in bookmarksQuerySnapshot.docs) {
          await doc.reference.delete();
        }
        
        // Actualizar caché
        if (article.url != null) {
          _bookmarkedUrls.remove(article.url!);
        }
        

        found = true;
      } else {
        // Intentar búsqueda alternativa por título si el URL no funcionó
        if (article.url != null && article.url!.isNotEmpty && article.title != null) {
          final alternativeQuery = await _firestore
              .collection(_bookmarksCollection)
              .where('title', isEqualTo: article.title)
              .get();
          
          if (alternativeQuery.docs.isNotEmpty) {
            for (final doc in alternativeQuery.docs) {
              await doc.reference.delete();
            }
            
            if (article.url != null) {
              _bookmarkedUrls.remove(article.url!);
            }
            

            found = true;
          }
        }
      }

      // 2. Buscar en artículos originales (artículos DNews o externos con saved=true)
      QuerySnapshot articlesQuerySnapshot;
      
      if (article.url != null && article.url!.isNotEmpty) {
        articlesQuerySnapshot = await _firestore
            .collection(_articlesCollection)
            .where('url', isEqualTo: article.url)
            .where('saved', isEqualTo: true)
            .get();
      } else {
        articlesQuerySnapshot = await _firestore
            .collection(_articlesCollection)
            .where('id', isEqualTo: article.id)
            .where('saved', isEqualTo: true)
            .get();
      }

      if (articlesQuerySnapshot.docs.isNotEmpty) {
        // Actualizar a saved = false en lugar de eliminar
        for (final doc in articlesQuerySnapshot.docs) {
          await doc.reference.update({'saved': false});
        }

        found = true;
      }
      
      if (!found) {

      }
    } catch (e) {

      throw Exception('Error al eliminar artículo guardado de Firestore: $e');
    }
  }

  @override
  Future<void> updateArticleSavedStatus(ArticleModel article, bool saved) async {
    try {

      
      QuerySnapshot querySnapshot;
      
      // Para artículos DNews, usar ID si no hay URL o si la URL está vacía
      if (article.source == 'DNews' && (article.url == null || article.url!.isEmpty)) {

        querySnapshot = await _firestore
            .collection(_articlesCollection)
            .where('id', isEqualTo: article.id)
            .get();
      } else {

        querySnapshot = await _firestore
            .collection(_articlesCollection)
            .where('url', isEqualTo: article.url)
            .get();
      }


      
      if (querySnapshot.docs.isNotEmpty) {
        // Actualizar el primer documento encontrado
        await querySnapshot.docs.first.reference.update({'saved': saved});

      } else {
        // Si estamos intentando guardar (saved = true) y el artículo no es DNews,
        // probablemente es un artículo de API que se eliminó de bookmarks
        if (saved && article.source != 'DNews') {
          await saveArticleAsBookmark(article);
          return;
        }
        
        // Intentar búsqueda alternativa por título si no se encontró (solo para DNews)
        if (article.title != null) {

          final titleQuerySnapshot = await _firestore
              .collection(_articlesCollection)
              .where('title', isEqualTo: article.title)
              .get();
          

          if (titleQuerySnapshot.docs.isNotEmpty) {
            await titleQuerySnapshot.docs.first.reference.update({'saved': saved});

          }
        }
      }
    } catch (e) {

      throw Exception('Error al actualizar estado de guardado en Firestore: $e');
    }
  }

  @override
  Future<bool> isArticleSaved(ArticleModel article) async {
    try {

      
      // Inicializar caché si es necesario
      await _initializeBookmarksCache();
      
      // Verificar en caché de bookmarks primero (más rápido)
      if (article.url != null && _bookmarkedUrls.contains(article.url!)) {

        return true;
      }

      // Buscar en artículos originales con saved = true
      QuerySnapshot articlesQuerySnapshot;
      
      // Para artículos DNews sin URL, usar ID
      if (article.source == 'DNews' && (article.url == null || article.url!.isEmpty)) {

        articlesQuerySnapshot = await _firestore
            .collection(_articlesCollection)
            .where('id', isEqualTo: article.id)
            .where('saved', isEqualTo: true)
            .limit(1)
            .get();
      } else {

        articlesQuerySnapshot = await _firestore
            .collection(_articlesCollection)
            .where('url', isEqualTo: article.url)
            .where('saved', isEqualTo: true)
            .limit(1)
            .get();
      }

      final isInArticles = articlesQuerySnapshot.docs.isNotEmpty;
      
      return isInArticles;
    } catch (e) {

      return false; // En caso de error, asumir que no está guardado
    }
  }


}
