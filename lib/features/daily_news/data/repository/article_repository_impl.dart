import 'dart:io';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/local/firestore_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/local/firebase_storage_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/models/article.dart';
import 'package:symmetry_showcase/core/constants/constants.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/calculate_lecture_time.dart';
import 'package:dio/dio.dart';

class ArticleRepositoryImpl implements ArticleRepository {

  final NewsApiService _newsApiService;
  final FirestoreService _firestoreService;
  final FirebaseStorageService _firebaseStorageService;
  final CalculateLectureTime _calculateLectureTime;

  ArticleRepositoryImpl(
    this._newsApiService, 
    this._firestoreService,
    this._firebaseStorageService,
    this._calculateLectureTime,
  );

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      // 1. Obtener artículos de Firestore y API (todas las categorías) en paralelo
      final results = await Future.wait([
        _getArticlesFromFirestore(),
        _getArticlesFromApiAllCategories(),
      ]);
      
      final firestoreArticles = results[0];
      final apiArticles = results[1];
      
      // 2. Combinar ambos resultados sin guardar API en Firebase
      final combinedArticles = _combineArticles(firestoreArticles, apiArticles);
      
      return DataSuccess(combinedArticles);
    } catch (e) {
      // Si falla la API, intentar devolver solo los de Firestore
      try {
        final firestoreArticles = await _getArticlesFromFirestore();
        if (firestoreArticles.isNotEmpty) {
          return DataSuccess(firestoreArticles);
        }
      } catch (_) {
        // Si también falla Firestore, devolver el error original
      }
      
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  Future<List<ArticleEntity>> _getArticlesFromFirestore() async {
    try {
      final firestoreArticles = await _firestoreService.getArticles();

      
      // Procesar artículos para asegurar que tengan lectureTime calculado
      final processedArticles = <ArticleEntity>[];
      
      for (final article in firestoreArticles) {
        if (article.lectureTime == null || article.lectureTime == 0) {
          // Calcular tiempo de lectura si no existe o es 0
          // Para artículos de Firebase, usar contenido + descripción si el contenido está vacío
          final content = (article.content?.isNotEmpty == true) 
              ? article.content! 
              : '${article.content ?? ''} ${article.description ?? ''}';
          final lectureTime = await _calculateLectureTime.call(
            CalculateLectureTimeParams(content: content),
          );
          
          // Crear nueva instancia con tiempo calculado
          final updatedArticle = ArticleModel(
            id: article.id,
            author: article.author,
            title: article.title,
            description: article.description,
            url: article.url,
            urlToImage: article.urlToImage,
            publishedAt: article.publishedAt,
            content: article.content,
            source: article.source,
            lectureTime: lectureTime,
            category: article.category,
            saved: article.saved,
          );
          processedArticles.add(updatedArticle);
        } else {
          // El artículo ya tiene tiempo de lectura válido
          processedArticles.add(article);
        }
      }
      
      return processedArticles.cast<ArticleEntity>();
    } catch (e) {

      // Si hay error en Firestore, devolver lista vacía para continuar con la API
      return [];
    }
  }

  Future<List<ArticleEntity>> _getArticlesFromApiAllCategories() async {
    final allArticles = <ArticleEntity>[];
    
    // Obtener artículos de todas las categorías en paralelo
    final futures = newsCategories.map((categoryName) async {
      try {
        final category = ArticleCategoryExtension.fromString(categoryName);
        return await _getArticlesFromApiByCategory(category);
      } catch (e) {

        return <ArticleEntity>[];
      }
    });
    
    final results = await Future.wait(futures);
    
    // Combinar todos los resultados
    for (final articles in results) {
      allArticles.addAll(articles);
    }
    
    return allArticles;
  }

  Future<List<ArticleEntity>> _getArticlesFromApiByCategory(ArticleCategory category) async {
    final httpResponse = await _newsApiService.getNewsArticles(
      apiKey, 
      country, 
      category.apiValue,
    );

    if (httpResponse.response.statusCode == 200) {
      // Extraer la lista de artículos del objeto de respuesta
      final articlesJson = httpResponse.data['articles'] as List<dynamic>;
      final articles = <ArticleEntity>[];
      
      for (final articleJson in articlesJson) {
        final articleMap = articleJson as Map<String, dynamic>;
        final articleModel = ArticleModel.fromJson(articleMap, category);
        
        // Calcular tiempo de lectura basado en el contenido (que ya incluye el patrón [+XXXX chars])
        final content = articleModel.content ?? '';
        
        final lectureTime = await _calculateLectureTime.call(
          CalculateLectureTimeParams(content: content),
        );
        
        // Crear una nueva instancia con el tiempo de lectura calculado
        final articleWithLectureTime = ArticleModel(
          id: articleModel.id,
          author: articleModel.author,
          title: articleModel.title,
          description: articleModel.description,
          url: articleModel.url,
          urlToImage: articleModel.urlToImage,
          publishedAt: articleModel.publishedAt,
          content: articleModel.content,
          source: articleModel.source,
          lectureTime: lectureTime,
          category: category,
          saved: false, // Los artículos de API no están guardados por defecto
        );
        
        articles.add(articleWithLectureTime);
      }
      
      return articles;
    } else {
      throw DioException(
        requestOptions: httpResponse.response.requestOptions,
        response: httpResponse.response,
        type: DioExceptionType.badResponse,
        error: httpResponse.response.statusMessage,
      );
    }
  }



  List<ArticleEntity> _combineArticles(
    List<ArticleEntity> firestoreArticles, 
    List<ArticleEntity> apiArticles,
  ) {
    final combinedList = <ArticleEntity>[];
    final urlsFromFirestore = <String>{};
    
    // Agregar todos los artículos de Firebase primero (ya tienen el estado saved correcto)
    for (final article in firestoreArticles) {
      combinedList.add(article);
      if (article.url != null) {
        urlsFromFirestore.add(article.url!);
      }
    }
    
    // Agregar artículos de la API solo si no están ya en Firebase
    // NO verificamos el estado guardado aquí para evitar lentitud
    for (final article in apiArticles) {
      if (article.url == null || !urlsFromFirestore.contains(article.url!)) {
        combinedList.add(article); // Se agrega con saved = false por defecto
      }
    }
    
    // Ordenar por fecha de publicación (más recientes primero)
    combinedList.sort((a, b) {
      if (a.publishedAt == null || b.publishedAt == null) return 0;
      return b.publishedAt!.compareTo(a.publishedAt!);
    });
    
    return combinedList;
  }





  @override
  Future<DataState<List<ArticleEntity>>> refreshNewsArticles() async {
    try {
      // Obtener artículos de ambas fuentes sin guardar API en Firebase
      final results = await Future.wait([
        _getArticlesFromFirestore(),
        _getArticlesFromApiAllCategories(),
      ]);
      
      final firestoreArticles = results[0];
      final apiArticles = results[1];
      
      // Combinar artículos manteniendo las fuentes separadas
      final combinedArticles = _combineArticles(firestoreArticles, apiArticles);
      
      return DataSuccess(combinedArticles);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getFirebaseArticles() async {
    try {
      // Solo obtener artículos de Firebase
      final firestoreArticles = await _getArticlesFromFirestore();
      return DataSuccess(firestoreArticles);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticlesByCategories(List<ArticleCategory> categories) async {
    try {
      final List<ArticleEntity> allArticles = [];
      
      // Obtener artículos de Firebase si se incluye DNews
      if (categories.contains(ArticleCategory.dnews)) {
        final firestoreArticles = await _getArticlesFromFirestore();
        allArticles.addAll(firestoreArticles);
      }
      
      // Obtener artículos de API para las categorías solicitadas (excluyendo DNews)
      final apiCategories = categories.where((cat) => cat != ArticleCategory.dnews).toList();
      if (apiCategories.isNotEmpty) {
        final futures = apiCategories.map((category) async {
          try {
            return await _getArticlesFromApiByCategory(category);
          } catch (e) {

            return <ArticleEntity>[];
          }
        });
        
        final results = await Future.wait(futures);
        for (final articles in results) {
          allArticles.addAll(articles);
        }
      }
      
      // Ordenar por fecha de publicación (más recientes primero)
      allArticles.sort((a, b) {
        if (a.publishedAt == null || b.publishedAt == null) return 0;
        return b.publishedAt!.compareTo(a.publishedAt!);
      });
      
      return DataSuccess(allArticles);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticlesByCategory(ArticleCategory category) async {
    try {
      if (category == ArticleCategory.dnews) {
        // Solo obtener artículos de Firebase
        final firestoreArticles = await _getArticlesFromFirestore();
        return DataSuccess(firestoreArticles);
      } else {
        // Obtener artículos de la API para la categoría específica
        final articles = await _getArticlesFromApiByCategory(category);
        return DataSuccess(articles);
      }
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  @override
  Future<DataState<void>> uploadArticle(ArticleEntity article) async {
    try {
      ArticleEntity processedArticle = article;
      
      // Si urlToImage es un path local, subir la imagen primero
      if (article.urlToImage != null && !article.urlToImage!.startsWith('http')) {
        final file = File(article.urlToImage!);
        if (await file.exists()) {
          final fileName = 'article_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final imageUrl = await _firebaseStorageService.uploadImage(file, fileName);
          
          // Actualizar el artículo con la URL de la imagen subida
          processedArticle = ArticleEntity(
            id: article.id,
            title: article.title,
            author: article.author,
            description: article.description,
            content: article.content,
            url: article.url,
            urlToImage: imageUrl,
            publishedAt: article.publishedAt,
            source: article.source,
            lectureTime: article.lectureTime,
            category: article.category,
            saved: article.saved,
          );
        }
      }
      
      // Calcular tiempo de lectura si no existe o es 0
      int lectureTime = processedArticle.lectureTime ?? 0;
      if (lectureTime == 0) {
        // Para artículos subidos, usar contenido + descripción
        final content = '${processedArticle.content ?? ''} ${processedArticle.description ?? ''}';
        lectureTime = await _calculateLectureTime.call(
          CalculateLectureTimeParams(content: content),
        );
      }
      
      // Crear un modelo de artículo con un ID único
      final articleModel = ArticleModel(
        id: DateTime.now().millisecondsSinceEpoch, // ID único basado en timestamp
        author: processedArticle.author,
        title: processedArticle.title,
        description: processedArticle.description,
        url: processedArticle.url,
        urlToImage: processedArticle.urlToImage,
        publishedAt: DateTime.now().toIso8601String(), // Fecha actual
        content: processedArticle.content,
        source: 'DNews', // Source fijo para artículos subidos por usuarios
        lectureTime: lectureTime,
        category: ArticleCategory.dnews, // Siempre DNews para artículos subidos
        saved: processedArticle.saved,
      );

      // Guardar en Firestore
      await _firestoreService.saveArticle(articleModel);

      
      return const DataSuccess(null);
    } catch (e) {

      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  @override
  Future<DataState<void>> saveArticle(ArticleEntity article) async {
    try {
      final articleModel = ArticleModel(
        id: article.id,
        author: article.author,
        title: article.title,
        description: article.description,
        url: article.url,
        urlToImage: article.urlToImage,
        publishedAt: article.publishedAt,
        content: article.content,
        source: article.source,
        lectureTime: article.lectureTime,
        category: article.category,
        saved: true, // Siempre true cuando guardamos
      );


      
      if (article.source == 'DNews' || article.category == ArticleCategory.dnews) {
        // Si es de Firebase, actualizar el estado

        await _firestoreService.updateArticleSavedStatus(articleModel, true);
      } else {
        // Si es de la API, guardarlo como nuevo documento en Firebase

        await _firestoreService.saveArticleAsBookmark(articleModel);
      }
      

      return const DataSuccess(null);
    } catch (e) {

      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  @override
  Future<DataState<void>> removeSavedArticle(ArticleEntity article) async {
    try {
      final articleModel = ArticleModel(
        id: article.id,
        author: article.author,
        title: article.title,
        description: article.description,
        url: article.url,
        urlToImage: article.urlToImage,
        publishedAt: article.publishedAt,
        content: article.content,
        source: article.source,
        lectureTime: article.lectureTime,
        category: article.category,
        saved: article.saved,
      );

      // Intentar eliminar de ambas colecciones
      // Esto maneja mejor los casos donde no sabemos exactamente dónde está guardado
      await _firestoreService.removeSavedArticle(articleModel);
      

      return const DataSuccess(null);
    } catch (e) {

      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() async {
    try {
      final savedArticles = await _firestoreService.getSavedArticles();
      return DataSuccess(savedArticles.cast<ArticleEntity>());
    } catch (e) {

      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }

  @override
  Future<DataState<bool>> isArticleSaved(ArticleEntity article) async {
    try {
      final articleModel = ArticleModel(
        id: article.id,
        author: article.author,
        title: article.title,
        description: article.description,
        url: article.url,
        urlToImage: article.urlToImage,
        publishedAt: article.publishedAt,
        content: article.content,
        source: article.source,
        lectureTime: article.lectureTime,
        category: article.category,
        saved: article.saved,
      );

      final isBookmarked = await _firestoreService.isArticleSaved(articleModel);
      return DataSuccess(isBookmarked);
    } catch (e) {

      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }
}