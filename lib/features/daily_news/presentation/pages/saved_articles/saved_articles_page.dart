import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/skeleton_views.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/saved_articles/saved_articles_state.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/saved_articles/saved_articles_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/bookmark/bookmark_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/bookmark/bookmark_article_state.dart';

class SavedArticlesPage extends StatefulWidget {
  const SavedArticlesPage({super.key});

  @override
  State<SavedArticlesPage> createState() => _SavedArticlesPageState();
}

class _SavedArticlesPageState extends State<SavedArticlesPage> {
  @override
  void initState() {
    super.initState();
    // Cargar artículos guardados al abrir la pantalla
    context.read<SavedArticlesBloc>().add(const GetSavedArticles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<BookmarkArticleBloc, BookmarkArticleState>(
          listener: (context, state) {
            if (state is BookmarkArticleRemoved) {
              // Cuando se elimina un artículo, refrescar la lista
              context.read<SavedArticlesBloc>().add(const RefreshSavedArticles());

            } else if (state is BookmarkArticleSaved) {
              // Cuando se guarda un artículo, refrescar la lista
              context.read<SavedArticlesBloc>().add(const RefreshSavedArticles());
              
            }
          },
          child: Column(
            children: [
              _buildCustomAppBar(context),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widgets de apoyo para mantener la limpieza en el widget principal

  Widget _buildHeader() {
    return BlocBuilder<SavedArticlesBloc, SavedArticlesState>(
      builder: (context, state) {
        int articlesCount = 0;
        if (state is SavedArticlesDone) {
          articlesCount = state.articles?.length ?? 0;
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bookmarks',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                '$articlesCount saved article' + (articlesCount == 1 ? '' : 's'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SavedArticlesBloc, SavedArticlesState>(
      builder: (context, state) {
        if (state is SavedArticlesLoading) {
          return _buildLoadingState();
        }
        
        if (state is SavedArticlesDone) {
          final savedArticles = state.articles ?? [];
          
          if (savedArticles.isEmpty) {
            return _buildEmptyState();
          }
          
          return _buildSavedArticlesList(savedArticles);
        }
        
        return _buildErrorState();
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 6, // +1 para el header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }
        return const Column(
          children: [
            SkeletonArticleTile(enableHero: false),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Divider(height: 1, color: AppColors.borderLight),
            ),
            SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSavedArticlesList(List<ArticleEntity> savedArticles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: ListView.builder(
        itemCount: savedArticles.length + 1, // +1 para el header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader();
          }
          final articleIndex = index - 1;
          final article = savedArticles[articleIndex];
          return Column(
            children: [
              ArticleTile(article: article, enableHero: false),
              if (articleIndex < savedArticles.length - 1) ...[
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Divider(height: 1, color: AppColors.borderLight),
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        _buildHeader(),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No saved articles yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Start saving articles by tapping the bookmark icon when reading.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        _buildHeader(),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Error loading saved articles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please try again later.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
