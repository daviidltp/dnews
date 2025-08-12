import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/upload_article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';

class UploadArticleBloc extends Bloc<UploadArticleEvent, UploadArticleState> {
  final UploadArticleUseCase _uploadArticleUseCase;

  UploadArticleBloc(this._uploadArticleUseCase) : super(const UploadArticleInitial()) {
    on<UploadArticle>(_onUploadArticle);
    on<ResetUploadState>(_onResetUploadState);
  }

  Future<void> _onUploadArticle(
    UploadArticle event,
    Emitter<UploadArticleState> emit,
  ) async {
    emit(const UploadArticleLoading());

    final dataState = await _uploadArticleUseCase(
      UploadArticleParams(article: event.article),
    );

    if (dataState is DataSuccess) {
      emit(const UploadArticleSuccess());
    } else if (dataState is DataFailed) {
      emit(UploadArticleFailed(exception: dataState.error!));
    }
  }

  void _onResetUploadState(
    ResetUploadState event,
    Emitter<UploadArticleState> emit,
  ) {
    emit(const UploadArticleInitial());
  }
}
