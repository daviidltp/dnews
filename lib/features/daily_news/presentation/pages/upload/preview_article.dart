import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/article_markdown_body.dart';

class PreviewArticlePage extends StatefulWidget {
  final String title;
  final String description;
  final String content;
  final File image;

  const PreviewArticlePage({
    super.key,
    required this.title,
    required this.description,
    required this.content,
    required this.image,
  });

  @override
  State<PreviewArticlePage> createState() => _PreviewArticlePageState();
}

class _PreviewArticlePageState extends State<PreviewArticlePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<UploadArticleBloc, UploadArticleState>(
        listener: (context, state) {
          if (state is UploadArticleSuccess) {
            // Regresar con resultado true para indicar éxito
            Navigator.of(context).pop(true);
          } else if (state is UploadArticleFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al subir artículo: ${state.exception.message}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              _buildCustomAppBar(),
              // Scrollable preview content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      _buildImagePreview(),
                      // Article content
                      _buildArticlePreview(),
                    ],
                  ),
                ),
              ),
              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: ClipRect(
        child: Image.file(
          widget.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
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

  Widget _buildArticlePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.title,
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
          Text(
            widget.description,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontFamily: 'Merriweather',
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
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
                      color: AppColors.accent,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
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
                    const Flexible(
                      child: Text(
                        'By David',
                        style: TextStyle(
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
                      '${_estimateReadingTime()} min read',
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
          
          const SizedBox(height: 24),
          
          // Content
          ArticleMarkdownBody(
            data: widget.content,
            blockquoteBorderWidth: 4,
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<UploadArticleBloc, UploadArticleState>(
        builder: (context, state) {
          final isLoading = state is UploadArticleLoading;
          
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ElevatedButton (
              onPressed: isLoading ? null : _submitArticle,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading ? AppColors.textSecondary : AppColors.textPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Uploading article...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Upload Article',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  int _estimateReadingTime() {
    // Estimación simple para mostrar en preview
    // La cálculación real se hará en el repositorio cuando se suba el artículo
    const wordsPerMinute = 200;
    final words = widget.content.split(RegExp(r'\s+')).length;
    final estimatedTime = (words / wordsPerMinute).ceil();
    return estimatedTime < 1 ? 1 : estimatedTime;
  }

  void _submitArticle() {
    // Crear un artículo temporal con datos básicos para iniciar el proceso de subida
    final article = ArticleEntity(
      title: widget.title.trim(),
      author: 'David',
      description: widget.description.trim(),
      content: widget.content.trim(),
      url: null,
      urlToImage: widget.image.path, // Path local, se procesará en el use case
      source: 'DNews',
      lectureTime: null, // Se calculará en el use case
    );
    
    // El bloc se encargará de emitir el estado de loading inmediatamente
    context.read<UploadArticleBloc>().add(UploadArticle(article: article));
  }




}
