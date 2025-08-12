import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/local/firestore_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/models/article.dart';
import 'package:symmetry_showcase/core/constants/constants.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/calculate_lecture_time.dart';
import 'package:dio/dio.dart';

class ArticleRepositoryImpl implements ArticleRepository {

  final NewsApiService _newsApiService;
  final FirestoreService _firestoreService;
  final CalculateLectureTime _calculateLectureTime;

  ArticleRepositoryImpl(
    this._newsApiService, 
    this._firestoreService,
    this._calculateLectureTime,
  );

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      // 1. Obtener artículos de Firestore y API en paralelo
      final results = await Future.wait([
        _getArticlesFromFirestore(),
        _getArticlesFromApi(),
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
      print('Firebase articles obtained: ${firestoreArticles.length}');
      return firestoreArticles.cast<ArticleEntity>();
    } catch (e) {
      print('Error getting Firebase articles: $e');
      // Si hay error en Firestore, devolver lista vacía para continuar con la API
      return [];
    }
  }

  Future<List<ArticleEntity>> _getArticlesFromApi() async {
    final httpResponse = await _newsApiService.getNewsArticles(
      apiKey, 
      country, 
      category,
    );

    if (httpResponse.response.statusCode == 200) {
      // Extraer la lista de artículos del objeto de respuesta
      final articlesJson = httpResponse.data['articles'] as List<dynamic>;
      final articles = <ArticleEntity>[];
      
      for (final articleJson in articlesJson) {
        final articleMap = articleJson as Map<String, dynamic>;
        final articleModel = ArticleModel.fromJson(articleMap);
        
        // Calcular tiempo de lectura basado en el contenido
        final lectureTime = await _calculateLectureTime.call(
          CalculateLectureTimeParams(content: articleModel.content ?? ''),
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
    // Simplemente combinar ambas listas sin evitar duplicados
    // ya que mantenemos las fuentes completamente separadas
    final combinedList = <ArticleEntity>[];
    
    // Agregar todos los artículos de Firebase primero
    combinedList.addAll(firestoreArticles);
    
    // Luego agregar todos los artículos de la API
    combinedList.addAll(apiArticles);
    
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
        _getArticlesFromApi(),
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
  Future<DataState<void>> uploadArticle(ArticleEntity article) async {
    try {
      // Crear un modelo de artículo con un ID único
      final articleModel = ArticleModel(
        id: DateTime.now().millisecondsSinceEpoch, // ID único basado en timestamp
        author: article.author,
        title: article.title,
        description: article.description,
        url: article.url,
        urlToImage: article.urlToImage,
        publishedAt: DateTime.now().toIso8601String(), // Fecha actual
        content: article.content,
        source: article.source ?? 'Usuario', // Source por defecto
        lectureTime: article.lectureTime,
      );

      print('Uploading article: ${articleModel.title}');
      // Guardar en Firestore
      await _firestoreService.saveArticle(articleModel);
      print('Article uploaded successfully to Firebase');
      
      return const DataSuccess(null);
    } catch (e) {
      print('Error uploading article: $e');
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }
}