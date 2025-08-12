import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/models/article.dart';
import 'package:symmetry_showcase/core/constants/constants.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/calculate_lecture_time.dart';
import 'package:dio/dio.dart';

class ArticleRepositoryImpl implements ArticleRepository {

  final NewsApiService _newsApiService;
  final CalculateLectureTime _calculateLectureTime;

  ArticleRepositoryImpl(this._newsApiService, this._calculateLectureTime);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
    final httpResponse = await _newsApiService.getNewsArticles(
      apiKey, 
      country, 
      category);

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
      
      return DataSuccess(articles);
    } else {
      return DataFailed(DioException(
        requestOptions: httpResponse.response.requestOptions,
        response: httpResponse.response,
        type: DioExceptionType.badResponse,
          error: httpResponse.response.statusMessage,
        ));
      }
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        error: e,
      ));
    }
  }
}