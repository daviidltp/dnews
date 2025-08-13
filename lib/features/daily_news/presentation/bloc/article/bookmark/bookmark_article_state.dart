import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

abstract class BookmarkArticleState extends Equatable {
  const BookmarkArticleState();
  
  @override
  List<Object> get props => [];
}

class BookmarkArticleInitial extends BookmarkArticleState {}

class BookmarkArticleLoading extends BookmarkArticleState {}

class BookmarkArticleSaved extends BookmarkArticleState {}

class BookmarkArticleRemoved extends BookmarkArticleState {}

class BookmarkArticleError extends BookmarkArticleState {
  final DioException error;
  
  const BookmarkArticleError({required this.error});
  
  @override
  List<Object> get props => [error];
}

class BookmarkStatusChecked extends BookmarkArticleState {
  final bool isBookmarked;
  
  const BookmarkStatusChecked({required this.isBookmarked});
  
  @override
  List<Object> get props => [isBookmarked];
}
