import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/core/usecases/usecase.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';

class GetFirebaseArticlesUseCase implements UseCase<DataState<List<ArticleEntity>>, void> {
  final ArticleRepository _articleRepository;

  GetFirebaseArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(void params) async {
    return _articleRepository.getFirebaseArticles();
  }
}
