import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  void onGetArticles(GetArticles event, Emitter<RemoteArticlesState> emit) async {
    final dataState = await _getArticleUseCase(null);

    if (dataState is DataSuccess && dataState.data != null) {
      emit(RemoteArticlesDone(dataState.data!));
    }

    if (dataState is DataFailed) {
      print(dataState.error);
      emit(RemoteArticlesError(dataState.error!));
    }
  }
}
