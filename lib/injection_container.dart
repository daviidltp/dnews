import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/local/firestore_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/local/firebase_storage_service.dart';
import 'package:symmetry_showcase/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_articles_by_categories.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_articles_by_category.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_firebase_articles.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/upload_article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/calculate_lecture_time.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/save_article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/remove_saved_article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_saved_articles.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/check_article_saved_status.dart';
import 'package:dio/dio.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/bookmark/bookmark_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerSingleton<Dio>(Dio());
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Data sources
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<FirestoreService>(FirestoreServiceImpl(sl()));
  sl.registerSingleton<FirebaseStorageService>(FirebaseStorageServiceImpl(sl()));

  // Use cases - Calculate lecture time (no dependencies)
  sl.registerSingleton<CalculateLectureTime>(CalculateLectureTime());

  // Repository (needs NewsApiService, FirestoreService, FirebaseStorageService and CalculateLectureTime)
  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl(), sl(), sl()));

  // Use cases - Get articles (needs ArticleRepository)
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  // Use cases - Get articles by categories (needs ArticleRepository)
  sl.registerSingleton<GetArticlesByCategoriesUseCase>(GetArticlesByCategoriesUseCase(sl()));

  // Use cases - Get articles by category (needs ArticleRepository)
  sl.registerSingleton<GetArticlesByCategoryUseCase>(GetArticlesByCategoryUseCase(sl()));

  // Use cases - Get Firebase articles (needs ArticleRepository)
  sl.registerSingleton<GetFirebaseArticlesUseCase>(GetFirebaseArticlesUseCase(sl()));

  // Use cases - Upload article (needs ArticleRepository)
  sl.registerSingleton<UploadArticleUseCase>(UploadArticleUseCase(sl()));

  // Use cases - Save article (needs ArticleRepository)
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  // Use cases - Remove saved article (needs ArticleRepository)
  sl.registerSingleton<RemoveSavedArticleUseCase>(RemoveSavedArticleUseCase(sl()));

  // Use cases - Get saved articles (needs ArticleRepository)
  sl.registerSingleton<GetSavedArticlesUseCase>(GetSavedArticlesUseCase(sl()));

  // Use cases - Check article saved status (needs ArticleRepository)
  sl.registerSingleton<CheckArticleSavedStatusUseCase>(CheckArticleSavedStatusUseCase(sl()));

  // Bloc
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));
  sl.registerFactory<UploadArticleBloc>(() => UploadArticleBloc(sl()));
  sl.registerFactory<BookmarkArticleBloc>(() => BookmarkArticleBloc(sl(), sl(), sl()));
  sl.registerFactory<SavedArticlesBloc>(() => SavedArticlesBloc(sl()));
}
