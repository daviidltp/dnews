import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_saved_articles.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/saved_articles/saved_articles_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/saved_articles/saved_articles_state.dart';

class SavedArticlesBloc extends Bloc<SavedArticlesEvent, SavedArticlesState> {
  final GetSavedArticlesUseCase _getSavedArticlesUseCase;
  
  SavedArticlesBloc(this._getSavedArticlesUseCase) : super(const SavedArticlesLoading()) {
    on<GetSavedArticles>(_onGetSavedArticles);
    on<RefreshSavedArticles>(_onRefreshSavedArticles);
    on<RemoveArticleFromList>(_onRemoveArticleFromList);
  }
  
  Future<void> _onGetSavedArticles(
    GetSavedArticles event,
    Emitter<SavedArticlesState> emit,
  ) async {
    emit(const SavedArticlesLoading());
    
    final dataState = await _getSavedArticlesUseCase.call(null);
    
    if (dataState is DataSuccess && dataState.data != null) {
      emit(SavedArticlesDone(dataState.data!));
    } else if (dataState is DataFailed) {
      emit(SavedArticlesError(dataState.error!));
    }
  }
  
  Future<void> _onRefreshSavedArticles(
    RefreshSavedArticles event,
    Emitter<SavedArticlesState> emit,
  ) async {
    final dataState = await _getSavedArticlesUseCase.call(null);
    
    if (dataState is DataSuccess && dataState.data != null) {
      emit(SavedArticlesDone(dataState.data!));
    } else if (dataState is DataFailed) {
      emit(SavedArticlesError(dataState.error!));
    }
  }
  
  void _onRemoveArticleFromList(
    RemoveArticleFromList event,
    Emitter<SavedArticlesState> emit,
  ) {
    if (state is SavedArticlesDone) {
      final currentArticles = (state as SavedArticlesDone).articles ?? [];
      final updatedArticles = currentArticles
          .where((article) => article.id != event.article.id)
          .toList();
      
      emit(SavedArticlesDone(updatedArticles));
    }
  }
}
