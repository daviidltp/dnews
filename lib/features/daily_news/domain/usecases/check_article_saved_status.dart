import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/core/usecases/usecase.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';

class CheckArticleSavedStatusUseCase implements UseCase<DataState<bool>, CheckArticleSavedStatusParams> {
  
  final ArticleRepository _articleRepository;
  
  CheckArticleSavedStatusUseCase(this._articleRepository);
  
  @override
  Future<DataState<bool>> call(CheckArticleSavedStatusParams params) {
    return _articleRepository.isArticleSaved(params.article);
  }
}

class CheckArticleSavedStatusParams {
  final ArticleEntity article;
  
  const CheckArticleSavedStatusParams({required this.article});
}
