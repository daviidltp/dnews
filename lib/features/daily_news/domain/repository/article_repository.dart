import 'package:symmetry_showcase/core/resources/data_state.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {

  Future<DataState<List<ArticleEntity>>> getNewsArticles();
  Future<DataState<List<ArticleEntity>>> refreshNewsArticles();
  Future<DataState<List<ArticleEntity>>> getFirebaseArticles();
  Future<DataState<List<ArticleEntity>>> getNewsArticlesByCategories(List<ArticleCategory> categories);
  Future<DataState<List<ArticleEntity>>> getNewsArticlesByCategory(ArticleCategory category);
  Future<DataState<void>> uploadArticle(ArticleEntity article);
  
  // Métodos para artículos guardados
  Future<DataState<void>> saveArticle(ArticleEntity article);
  Future<DataState<void>> removeSavedArticle(ArticleEntity article);
  Future<DataState<List<ArticleEntity>>> getSavedArticles();
  Future<DataState<bool>> isArticleSaved(ArticleEntity article);

}