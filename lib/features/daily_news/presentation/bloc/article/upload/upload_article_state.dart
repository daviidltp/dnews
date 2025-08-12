import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

abstract class UploadArticleState extends Equatable {
  const UploadArticleState();

  @override
  List<Object?> get props => [];
}

class UploadArticleInitial extends UploadArticleState {
  const UploadArticleInitial();
}

class UploadArticleLoading extends UploadArticleState {
  const UploadArticleLoading();
}

class UploadArticleSuccess extends UploadArticleState {
  const UploadArticleSuccess();
}

class UploadArticleFailed extends UploadArticleState {
  final DioException exception;

  const UploadArticleFailed({required this.exception});

  @override
  List<Object?> get props => [exception];
}
