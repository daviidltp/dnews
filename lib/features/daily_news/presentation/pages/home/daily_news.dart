import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/featured_article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/sticky_category_buttons.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/pages/upload/upload_article.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/cubit/category_selection_cubit.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategorySelectionCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _buildBody(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToUpload(context),
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.edit_note_sharp),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo y icono de marcados en la misma fila
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo con manejo de errores robusto
              Container(
                height: 50,
                width: 50,
                child: Builder(
                  builder: (context) {
                    try {
                      return Image.asset(
                        'assets/images/logo_extended.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          );
                        },
                      );
                    } catch (e) {
                      // Fallback si hay algún error
                      return Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bookmark_border_outlined,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24), // Espacio entre logo y header
          Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            _getCurrentDate(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    // Usamos nombres de meses en español manualmente para evitar problemas de localización
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final monthName = months[now.month - 1];
    return '$monthName ${now.day}';
  }

  String _getGreeting() {
    final now = DateTime.now();
    if (now.hour < 12) {
      return 'Good morning';
    } else if (now.hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }



  Widget _buildBody() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        // Solo mostrar loading completo si no hay artículos previos
        if (state is RemoteArticlesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        // Para RemoteArticlesDone, mostrar contenido
        if (state is RemoteArticlesDone) {
          final articles = state.filteredArticles ?? [];
          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCustomHeader(context),
                  const SizedBox(height: 20),
                  const Text('No hay artículos disponibles'),
                ],
              ),
            );
          }
          
          return CustomScrollView(
            slivers: [
              // Header como SliverToBoxAdapter
              SliverToBoxAdapter(
                child: _buildCustomHeader(context),
              ),
              // Botones sticky
              const StickyCategoryButtons(),
              // Lista de artículos
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      // Primera noticia en formato destacado
                      return Column(
                        children: [
                          FeaturedArticleTile(article: articles[index]),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16), 
                            child: Divider(height: 1, color: AppColors.borderLight),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 24, top: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Top headlines',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Resto de noticias en formato normal
                      return Column(
                        children: [
                          ArticleTile(article: articles[index]),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16), 
                            child: Divider(height: 1, color: AppColors.borderLight),
                          ),
                        ],
                      );
                    }
                  },
                  childCount: articles.length,
                ),
              ),
            ],
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCustomHeader(context),
              const SizedBox(height: 20),
              const Text('Error al cargar las noticias'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToUpload(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => const UploadArticlePage(),
      ),
    );
    
    // Si el artículo se subió exitosamente, refrescar solo los artículos de Firebase
    if (result == true && context.mounted) {
      context.read<RemoteArticlesBloc>().add(const RefreshFirebaseArticles());
    }
  }
}
