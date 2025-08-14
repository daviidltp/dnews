import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/core/usecases/usecase.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/repository/article_repository.dart';

class UploadArticleParams {
  final ArticleEntity article;

  const UploadArticleParams({required this.article});
}

class UploadArticleUseCase implements UseCase<DataState<void>, UploadArticleParams> {
  final ArticleRepository _articleRepository;

  UploadArticleUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call(UploadArticleParams params) async {
    // El use case ahora simplemente delega toda la lógica al repositorio
    // siguiendo los principios de Clean Architecture
    return await _articleRepository.uploadArticle(params.article);
  }
}
