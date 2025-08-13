import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? allArticles; // Todos los artículos cargados
  final List<ArticleEntity>? filteredArticles; // Artículos filtrados por categoría
  final DioException? error;
  final List<ArticleCategory>? selectedCategories;

  const RemoteArticlesState({
    this.allArticles,
    this.filteredArticles, 
    this.error, 
    this.selectedCategories,
  });

  @override
  List<Object?> get props => [allArticles, filteredArticles, error, selectedCategories];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone({
    required List<ArticleEntity> allArticles,
    required List<ArticleEntity> filteredArticles,
    List<ArticleCategory>? selectedCategories,
  }) : super(
         allArticles: allArticles,
         filteredArticles: filteredArticles, 
         selectedCategories: selectedCategories,
       );
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(DioException error) : super(error: error);
}
