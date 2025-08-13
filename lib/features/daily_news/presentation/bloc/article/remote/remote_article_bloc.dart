import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(
    this._getArticleUseCase,
  ) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
    on<RefreshFirebaseArticles>(onRefreshFirebaseArticles);
    on<FilterArticlesByCategories>(onFilterArticlesByCategories);
  }

  void onGetArticles(GetArticles event, Emitter<RemoteArticlesState> emit) async {
    emit(const RemoteArticlesLoading());
    
    final dataState = await _getArticleUseCase(null);

    if (dataState is DataSuccess && dataState.data != null) {
      final allArticles = dataState.data!;
      // Por defecto mostrar General + DNews
      final defaultCategories = [ArticleCategory.general, ArticleCategory.dnews];
      final filteredArticles = _filterArticlesByCategories(allArticles, defaultCategories);
      
      emit(RemoteArticlesDone(
        allArticles: allArticles,
        filteredArticles: filteredArticles,
        selectedCategories: defaultCategories,
      ));
    }

    if (dataState is DataFailed) {
      print(dataState.error);
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  void onRefreshFirebaseArticles(RefreshFirebaseArticles event, Emitter<RemoteArticlesState> emit) async {
    print('RefreshFirebaseArticles event triggered');
    
    // Agregar un pequeño delay para asegurar que Firebase haya propagado los cambios
    await Future.delayed(const Duration(milliseconds: 500));
    
    final dataState = await _getArticleUseCase(null); // Obtener todos los artículos (API + Firebase)

    if (dataState is DataSuccess && dataState.data != null) {
      print('RefreshFirebaseArticles: ${dataState.data!.length} artículos obtenidos');
      
      final currentState = state;
      final selectedCategories = currentState is RemoteArticlesDone 
          ? currentState.selectedCategories ?? [ArticleCategory.general, ArticleCategory.dnews]
          : [ArticleCategory.general, ArticleCategory.dnews];
      
      final allArticles = dataState.data!;
      final filteredArticles = _filterArticlesByCategories(allArticles, selectedCategories);
      
      emit(RemoteArticlesDone(
        allArticles: allArticles,
        filteredArticles: filteredArticles,
        selectedCategories: selectedCategories,
      ));
    } else if (dataState is DataFailed) {
      print('RefreshFirebaseArticles error: ${dataState.error}');
      emit(RemoteArticlesError(dataState.error!));
    }
  }

  // Métodos eliminados - ahora usamos solo filtrado local

  void onFilterArticlesByCategories(FilterArticlesByCategories event, Emitter<RemoteArticlesState> emit) {
    final currentState = state;
    if (currentState is RemoteArticlesDone && currentState.allArticles != null) {
      final filteredArticles = _filterArticlesByCategories(currentState.allArticles!, event.categories);
      
      emit(RemoteArticlesDone(
        allArticles: currentState.allArticles!,
        filteredArticles: filteredArticles,
        selectedCategories: event.categories,
      ));
    }
  }

  List<ArticleEntity> _filterArticlesByCategories(List<ArticleEntity> articles, List<ArticleCategory> categories) {
    return articles.where((article) => categories.contains(article.category)).toList();
  }
}
