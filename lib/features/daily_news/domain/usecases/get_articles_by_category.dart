import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/core/usecases/usecase.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';

class GetArticlesByCategoryParams {
  final ArticleCategory category;

  const GetArticlesByCategoryParams({required this.category});
}

class GetArticlesByCategoryUseCase implements UseCase<DataState<List<ArticleEntity>>, GetArticlesByCategoryParams> {
  final ArticleRepository _articleRepository;

  GetArticlesByCategoryUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(GetArticlesByCategoryParams params) async {
    return _articleRepository.getNewsArticlesByCategory(params.category);
  }
}
