import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:symmetry_showcase/core/constants/constants.dart';

part 'news_api_service.g.dart';

@RestApi(baseUrl: newsAPIURL)
abstract class NewsApiService {
  factory NewsApiService(Dio dio) = _NewsApiService;

  @GET('/top-headlines')
  Future<HttpResponse<Map<String, dynamic>>> getNewsArticles(
    @Query('apiKey') String apiKey,
    @Query('country') String country,
    @Query('category') String category,
  );
} 