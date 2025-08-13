import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

abstract class SavedArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final DioException? error;
  
  const SavedArticlesState({this.articles, this.error});
  
  @override
  List<Object?> get props => [articles, error];
}

class SavedArticlesLoading extends SavedArticlesState {
  const SavedArticlesLoading();
}

class SavedArticlesDone extends SavedArticlesState {
  const SavedArticlesDone(List<ArticleEntity> articles) : super(articles: articles);
}

class SavedArticlesError extends SavedArticlesState {
  const SavedArticlesError(DioException error) : super(error: error);
}
