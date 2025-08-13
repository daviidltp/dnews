import 'package:equatable/equatable.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

abstract class BookmarkArticleEvent extends Equatable {
  final ArticleEntity article;
  
  const BookmarkArticleEvent({required this.article});
  
  @override
  List<Object> get props => [article];
}

class SaveBookmarkArticle extends BookmarkArticleEvent {
  const SaveBookmarkArticle({required super.article});
}

class RemoveBookmarkArticle extends BookmarkArticleEvent {
  const RemoveBookmarkArticle({required super.article});
}

class CheckBookmarkStatus extends BookmarkArticleEvent {
  const CheckBookmarkStatus({required super.article});
}
