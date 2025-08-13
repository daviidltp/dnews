import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/core/usecases/usecase.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';

class SaveArticleUseCase implements UseCase<DataState<void>, SaveArticleParams> {
  
  final ArticleRepository _articleRepository;
  
  SaveArticleUseCase(this._articleRepository);
  
  @override
  Future<DataState<void>> call(SaveArticleParams params) {
    return _articleRepository.saveArticle(params.article);
  }
}

class SaveArticleParams {
  final ArticleEntity article;
  
  const SaveArticleParams({required this.article});
}
