import 'package:get_it/get_it.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/calculate_lecture_time.dart';
import 'package:dio/dio.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {

  // Core
  sl.registerSingleton<Dio>(Dio());

  // Data sources
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  // Use cases - Calculate lecture time (no dependencies)
  sl.registerSingleton<CalculateLectureTime>(CalculateLectureTime());

  // Repository (needs NewsApiService and CalculateLectureTime)
  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  // Use cases - Get articles (needs ArticleRepository)
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  // Bloc
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
}
