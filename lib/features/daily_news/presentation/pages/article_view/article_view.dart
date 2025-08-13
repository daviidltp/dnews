import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/bookmark/bookmark_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/bookmark/bookmark_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/bookmark/bookmark_article_state.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/article_markdown_body.dart';

class ArticleViewPage extends StatefulWidget {
  final ArticleEntity article;

  const ArticleViewPage({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<ArticleViewPage> createState() => _ArticleViewPageState();
}

class _ArticleViewPageState extends State<ArticleViewPage> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.article.saved;

    
    // Verificar el estado actual del bookmark después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Forzar que el BLoC esté en estado inicial antes de la consulta
      final bloc = context.read<BookmarkArticleBloc>();
      bloc.add(CheckBookmarkStatus(article: widget.article));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            _buildCustomAppBar(context),
            // Scrollable article content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article image
                    _buildArticleImage(),
                    // Article content
                    _buildArticleContent(),
                  ],
                ),
              ),
            ),
          ],
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
          const Spacer(),
          // Bookmark button
          BlocConsumer<BookmarkArticleBloc, BookmarkArticleState>(
            listenWhen: (previous, current) {
              return true; // Escuchar todos los cambios
            },
            listener: (context, state) {
              if (state is BookmarkArticleSaved) {
                setState(() {
                  _isBookmarked = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Artículo guardado'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (state is BookmarkArticleRemoved) {
                setState(() {
                  _isBookmarked = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Artículo eliminado de guardados'),
                    backgroundColor: AppColors.textSecondary,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (state is BookmarkStatusChecked) {
                setState(() {
                  _isBookmarked = state.isBookmarked;
                });
              } else if (state is BookmarkArticleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.error.message}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is BookmarkArticleLoading;
              
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : () {
                    if (_isBookmarked) {
                      context.read<BookmarkArticleBloc>().add(
                        RemoveBookmarkArticle(article: widget.article),
                      );
                    } else {
                      context.read<BookmarkArticleBloc>().add(
                        SaveBookmarkArticle(article: widget.article),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          )
                        : Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: _isBookmarked ? AppColors.primary : AppColors.textPrimary,
                            size: 24,
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    if (widget.article.urlToImage == null || widget.article.urlToImage!.isEmpty) {
      return Container(
        height: 350,
        width: double.infinity,
        color: AppColors.surface,
        child: const Icon(
          Icons.article,
          color: AppColors.textTertiary,
          size: 80,
        ),
      );
    }

    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Hero(
        tag: 'article_image_${widget.article.id ?? widget.article.title ?? widget.article.urlToImage}',
        child: CachedNetworkImage(
          imageUrl: widget.article.urlToImage!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.surface,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.surface,
            child: const Icon(
              Icons.image_not_supported,
              color: AppColors.textTertiary,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (widget.article.title != null && widget.article.title!.isNotEmpty)
            Text(
              widget.article.title!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Merriweather',
                height: 1.2,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Description
          if (widget.article.description != null && widget.article.description!.isNotEmpty)
            Text(
              widget.article.description!,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontFamily: 'Merriweather',
                height: 1.2,
              ),
            ),
          
          const SizedBox(height: 8),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          
          const SizedBox(height: 4),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.newspaper,
                      color: widget.article.source == 'DNews' ? AppColors.textPrimary : AppColors.textSecondary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: widget.article.source == 'DNews' 
                        ? RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'D',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: 'News',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            widget.article.source ?? 'Anónimo',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        'By ${widget.article.author ?? 'Anónimo'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      '${widget.article.lectureTime} min read',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Author and reading time info
         
          
          const SizedBox(height: 24),
          
          // Content
          if (widget.article.content != null && widget.article.content!.isNotEmpty)
            ArticleMarkdownBody(
              data: widget.article.content!,
            ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
