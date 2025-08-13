import 'package:equatable/equatable.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

abstract class RemoteArticlesEvent extends Equatable {
  const RemoteArticlesEvent();

  @override
  List<Object> get props => [];
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class RefreshFirebaseArticles extends RemoteArticlesEvent {
  const RefreshFirebaseArticles();
}

class GetArticlesByCategories extends RemoteArticlesEvent {
  final List<ArticleCategory> categories;

  const GetArticlesByCategories(this.categories);

  @override
  List<Object> get props => [categories];
}

class GetArticlesByCategory extends RemoteArticlesEvent {
  final ArticleCategory category;

  const GetArticlesByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class FilterArticlesByCategories extends RemoteArticlesEvent {
  final List<ArticleCategory> categories;

  const FilterArticlesByCategories(this.categories);

  @override
  List<Object> get props => [categories];
}