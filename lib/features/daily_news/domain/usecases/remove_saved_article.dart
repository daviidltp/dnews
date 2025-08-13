import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/core/usecases/usecase.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';

class RemoveSavedArticleUseCase implements UseCase<DataState<void>, RemoveSavedArticleParams> {
  
  final ArticleRepository _articleRepository;
  
  RemoveSavedArticleUseCase(this._articleRepository);
  
  @override
  Future<DataState<void>> call(RemoveSavedArticleParams params) {
    return _articleRepository.removeSavedArticle(params.article);
  }
}

class RemoveSavedArticleParams {
  final ArticleEntity article;
  
  const RemoveSavedArticleParams({required this.article});
}
