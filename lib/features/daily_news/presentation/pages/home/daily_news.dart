import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:confetti/confetti.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/featured_article_tile.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/sticky_category_buttons.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/skeleton_views.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/pages/upload/upload_article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/pages/saved_articles/saved_articles_page.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/cubit/category_selection_cubit.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({super.key});

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategorySelectionCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SafeArea(
              child: _buildBody(),
            ),
            // Confetti widget
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.57, // radians - hacia abajo
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 90,
                gravity: 0.05,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
            // Botón de crear artículo posicionado absolutamente
            Positioned(
              bottom: 30,
              right: 30,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(64),
                color: AppColors.textPrimary,
                child: InkWell(
                  onTap: () => _navigateToUpload(context),
                  borderRadius: BorderRadius.circular(64),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(64),
                    ),
                    child: const Icon(
                      Icons.edit_note_sharp,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToSavedArticles(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Espacio entre logo y header
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
        // Mostrar skeleton con shimmer durante la carga
        if (state is RemoteArticlesLoading) {
          return _buildSkeletonView();
        }
        
        // Para RemoteArticlesDone, mostrar contenido
        if (state is RemoteArticlesDone) {
          final articles = state.filteredArticles ?? [];
          return _buildContentView(articles);
        }
        
        return _buildErrorState();
      },
    );
  }

  Widget _buildSkeletonView() {
    return CustomScrollView(
      slivers: [
        // Header normal (sin skeleton)
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) => _buildCustomHeader(context),
          ),
        ),
        // Botones sticky normales (sin skeleton)
        const StickyCategoryButtons(),
        // Lista de artículos con skeleton
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  // Primera noticia skeleton en formato destacado
                  return Column(
                    children: [
                      SkeletonFeaturedArticleTile(uniqueId: -1000), // ID único negativo para skeleton
                      // Siempre mostrar divider y "Top headlines" en skeleton ya que simula múltiples artículos
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
                  // Resto de noticias skeleton en formato normal
                  return Column(
                    children: [
                      SkeletonArticleTile(uniqueId: -1000 - index), // ID único negativo para cada skeleton
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16), 
                        child: Divider(height: 1, color: AppColors.borderLight),
                      ),
                    ],
                  );
                }
              },
              childCount: 5, // Mostrar 5 elementos skeleton
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoArticlesMessage() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ups! No articles were found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try selecting another category or refresh to see more content.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(List articles) {
    return CustomScrollView(
      slivers: [
        // Header como SliverToBoxAdapter
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) => _buildCustomHeader(context),
          ),
        ),
        // Botones sticky
        const StickyCategoryButtons(),
        // Lista de artículos o mensaje de vacío
        if (articles.isEmpty)
          _buildNoArticlesMessage()
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                                if (index == 0) {
                  // Primera noticia en formato destacado
                  return Column(
                    children: [
                      FeaturedArticleTile(article: articles[index]),
                      // Solo mostrar divider y "Top headlines" si hay más de un artículo
                      if (articles.length > 1) ...[
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
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(
            builder: (context) => _buildCustomHeader(context),
          ),
          const SizedBox(height: 20),
          const Text('Error al cargar las noticias'),
        ],
      ),
    );
  }

  Future<void> _navigateToUpload(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (context) => const UploadArticlePage(),
      ),
    );
    
    // Si el artículo se subió exitosamente, mostrar confetti y snackbar, luego refrescar artículos
    if (result == true && context.mounted) {
      _showSuccessWithConfetti();
      context.read<RemoteArticlesBloc>().add(const RefreshFirebaseArticles());
    }
  }

  void _showSuccessWithConfetti() {
    // Iniciar la animación de confetti
    _confettiController.play();
    
    // Mostrar el snackbar mejorado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Success!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Article uploaded successfully',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _navigateToSavedArticles(BuildContext context) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SavedArticlesPage(),
      ),
    );
  }
}
