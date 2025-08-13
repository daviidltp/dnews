import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/core/usecases/usecase.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';

class GetArticlesByCategoriesParams {
  final List<ArticleCategory> categories;

  const GetArticlesByCategoriesParams({required this.categories});
}

class GetArticlesByCategoriesUseCase implements UseCase<DataState<List<ArticleEntity>>, GetArticlesByCategoriesParams> {
  final ArticleRepository _articleRepository;

  GetArticlesByCategoriesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(GetArticlesByCategoriesParams params) async {
    return _articleRepository.getNewsArticlesByCategories(params.categories);
  }
}
