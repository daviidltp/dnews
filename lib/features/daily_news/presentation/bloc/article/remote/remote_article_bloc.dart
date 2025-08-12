import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/get_article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:symmetry_showcase/core/resources/data_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
    on<RefreshFirebaseArticles>(onRefreshFirebaseArticles);
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

  void onRefreshFirebaseArticles(RefreshFirebaseArticles event, Emitter<RemoteArticlesState> emit) async {
    print('RefreshFirebaseArticles event triggered');
    
    // Agregar un pequeño delay para asegurar que Firebase haya propagado los cambios
    await Future.delayed(const Duration(milliseconds: 500));
    
    final dataState = await _getArticleUseCase(null); // Obtener todos los artículos (API + Firebase)

    if (dataState is DataSuccess && dataState.data != null) {
      print('RefreshFirebaseArticles: ${dataState.data!.length} artículos obtenidos');
      
      // Forzar un nuevo estado incluso si la lista es la misma
      // Esto asegura que la UI se actualice
      emit(const RemoteArticlesLoading());
      await Future.delayed(const Duration(milliseconds: 100)); // Pequeño delay
      emit(RemoteArticlesDone(dataState.data!));
    } else if (dataState is DataFailed) {
      print('RefreshFirebaseArticles error: ${dataState.error}');
      // Si falla, obtener el estado actual y re-emitirlo
      final currentState = state;
      if (currentState is RemoteArticlesDone) {
        emit(RemoteArticlesDone(currentState.articles!));
      } else {
        emit(RemoteArticlesError(dataState.error!));
      }
    }
  }
}
