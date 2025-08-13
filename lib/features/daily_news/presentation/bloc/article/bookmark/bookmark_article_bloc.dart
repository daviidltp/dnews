import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/save_article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/remove_saved_article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/check_article_saved_status.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/bookmark/bookmark_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/bookmark/bookmark_article_state.dart';

class BookmarkArticleBloc extends Bloc<BookmarkArticleEvent, BookmarkArticleState> {
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveSavedArticleUseCase _removeSavedArticleUseCase;
  final CheckArticleSavedStatusUseCase _checkArticleSavedStatusUseCase;

  BookmarkArticleBloc(
    this._saveArticleUseCase,
    this._removeSavedArticleUseCase,
    this._checkArticleSavedStatusUseCase,
  ) : super(BookmarkArticleInitial()) {
    on<SaveBookmarkArticle>(_onSaveBookmarkArticle);
    on<RemoveBookmarkArticle>(_onRemoveBookmarkArticle);
    on<CheckBookmarkStatus>(_onCheckBookmarkStatus);
  }

  Future<void> _onSaveBookmarkArticle(
    SaveBookmarkArticle event,
    Emitter<BookmarkArticleState> emit,
  ) async {
    emit(BookmarkArticleLoading());

    final dataState = await _saveArticleUseCase.call(
      SaveArticleParams(article: event.article),
    );

    if (dataState is DataSuccess) {
      emit(BookmarkArticleSaved());
    } else if (dataState is DataFailed) {
      emit(BookmarkArticleError(error: dataState.error!));
    }
  }

  Future<void> _onRemoveBookmarkArticle(
    RemoveBookmarkArticle event,
    Emitter<BookmarkArticleState> emit,
  ) async {
    emit(BookmarkArticleLoading());

    final dataState = await _removeSavedArticleUseCase.call(
      RemoveSavedArticleParams(article: event.article),
    );

    if (dataState is DataSuccess) {
      emit(BookmarkArticleRemoved());
    } else if (dataState is DataFailed) {
      emit(BookmarkArticleError(error: dataState.error!));
    }
  }

  Future<void> _onCheckBookmarkStatus(
    CheckBookmarkStatus event,
    Emitter<BookmarkArticleState> emit,
  ) async {
    // Siempre empezar desde loading para forzar un cambio de estado
    emit(BookmarkArticleLoading());
    
    final dataState = await _checkArticleSavedStatusUseCase.call(
      CheckArticleSavedStatusParams(article: event.article),
    );

    if (dataState is DataSuccess) {
      emit(BookmarkStatusChecked(isBookmarked: dataState.data!));
    } else if (dataState is DataFailed) {
      emit(BookmarkArticleError(error: dataState.error!));
    }
  }
}
