import 'package:equatable/equatable.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

abstract class SavedArticlesEvent extends Equatable {
  const SavedArticlesEvent();
  
  @override
  List<Object> get props => [];
}

class GetSavedArticles extends SavedArticlesEvent {
  const GetSavedArticles();
}

class RefreshSavedArticles extends SavedArticlesEvent {
  const RefreshSavedArticles();
}

class RemoveArticleFromList extends SavedArticlesEvent {
  final ArticleEntity article;
  
  const RemoveArticleFromList(this.article);
  
  @override
  List<Object> get props => [article];
}
