import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/featured_article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/pages/upload/upload_article.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/cubit/button_selection_cubit.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ButtonSelectionCubit(),
      child: Scaffold(
        body: _buildBody(),
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
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo y icono de marcados en la misma fila
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo con manejo de errores robusto
              Container(
                height: 30,
                width: 30,
                child: Builder(
                  builder: (context) {
                    try {
                      return Image.asset(
                        'assets/images/logo_upscaled.png',
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
          const SizedBox(height: 8), // Espacio entre logo y header
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
          const SizedBox(height: 24), // Espacio entre fecha y botones
          BlocBuilder<ButtonSelectionCubit, int>(
            builder: (context, selectedIndex) {
              return Wrap(
                spacing: 8, // Reducir el gap horizontal entre botones
                runSpacing: 8, // Gap vertical si hay wrap
                alignment: WrapAlignment.start, // Alinear a la izquierda
                children: [
                  _buildSelectionButton(
                    context: context,
                    text: 'General',
                    index: 0,
                    isSelected: selectedIndex == 0,
                  ),
                  _buildSelectionButton(
                    context: context,
                    text: 'Business',
                    index: 1,
                    isSelected: selectedIndex == 1,
                  ),
                  _buildSelectionButton(
                    context: context,
                    text: 'Sports',
                    index: 2,
                    isSelected: selectedIndex == 2,
                  ),
                  
                ],
              );
            },
          ),
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

  Widget _buildSelectionButton({
    required BuildContext context,
    required String text,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<ButtonSelectionCubit>().selectButton(index);
      },
      child: Container(
        height: 34,
        width: 90,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(60),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is RemoteArticlesDone) {
          final articles = state.articles ?? [];
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
          
          return ListView.builder(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            itemCount: articles.length + 1, // +1 para el header
            itemBuilder: (context, index) {
              if (index == 0) {
                // Header como primer elemento
                return _buildCustomHeader(context);
              } else if (index == 1) {
                // Primera noticia en formato destacado
                return Column(
                  children: [
                    FeaturedArticleTile(article: articles[index - 1]),
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
                    ArticleTile(article: articles[index - 1]),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16), 
                      child: Divider(height: 1, color: AppColors.borderLight),
                    ),
                  ],
                );
              }
            },
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
