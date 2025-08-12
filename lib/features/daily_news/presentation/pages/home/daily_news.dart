import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/featured_article_tile.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar acción del botón
        },
        backgroundColor: AppColors.textPrimary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DNews',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
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
          Text(
            _getCurrentDate(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: AppColors.textSecondary,
            ),
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
}
