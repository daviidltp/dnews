import 'package:equatable/equatable.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

abstract class UploadArticleEvent extends Equatable {
  const UploadArticleEvent();

  @override
  List<Object?> get props => [];
}

class UploadArticle extends UploadArticleEvent {
  final ArticleEntity article;

  const UploadArticle({required this.article});

  @override
  List<Object?> get props => [article];
}

class ResetUploadState extends UploadArticleEvent {
  const ResetUploadState();
}
