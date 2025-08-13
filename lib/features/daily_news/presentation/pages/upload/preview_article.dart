import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';
import 'package:symmetry_showcase/features/daily_news/domain/usecases/calculate_lecture_time.dart';
import 'package:symmetry_showcase/features/daily_news/data/data_sources/local/firebase_storage_service.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_event.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/resizing_button.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/animated_image_picker.dart';
import 'package:symmetry_showcase/injection_container.dart';

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
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<UploadArticleBloc, UploadArticleState>(
        listener: (context, state) {
          if (state is UploadArticleSuccess) {
            setState(() {
              _isUploadingImage = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Artículo subido exitosamente!'),
                backgroundColor: Colors.green,
              ),
            );
            // Regresar a la pantalla principal (cerrar tanto preview como upload)
            // y retornar true para indicar que el artículo se subió exitosamente
            Navigator.of(context).pop(true);
          } else if (state is UploadArticleFailed) {
            setState(() {
              _isUploadingImage = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al subir artículo: ${state.exception.message}'),
                backgroundColor: Colors.red,
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
                    const Expanded(
                      child: Text(
                        'DNews',
                        style: TextStyle(
                          color: AppColors.accent,
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
                    FutureBuilder<int>(
                      future: _calculateReadingTime(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            '${snapshot.data} min read',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text(
                          'Calculando...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Content
          MarkdownBody(
            data: widget.content,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontFamily: 'Merriweather',
                height: 1.6,
              ),
              h1: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Merriweather',
                height: 1.3,
              ),
              h2: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Merriweather',
                height: 1.3,
              ),
              h3: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Merriweather',
                height: 1.3,
              ),
              strong: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Merriweather',
              ),
              em: const TextStyle(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
                fontFamily: 'Merriweather',
              ),
              code: TextStyle(
                backgroundColor: AppColors.surface,
                color: AppColors.textPrimary,
                fontFamily: 'Merriweather',
                fontSize: 14,
              ),
              codeblockDecoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              blockquote: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontFamily: 'Merriweather',
              ),
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppColors.textPrimary.withOpacity(0.3),
                    width: 4,
                  ),
                ),
              ),
            ),
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
          final isLoading = state is UploadArticleLoading || _isUploadingImage;
          
          return ResizingButton(
            onPressed: isLoading ? null : _submitArticle,
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            borderRadius: BorderRadius.circular(16),
            elevation: 2,
            shadowColor: AppColors.textPrimary.withOpacity(0.3),
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
                      Text(
                        _isUploadingImage ? 'Subiendo imagen...' : 'Guardando artículo...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Publicar Artículo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<int> _calculateReadingTime() async {
    final calculateLectureTime = sl<CalculateLectureTime>();
    return await calculateLectureTime.call(
      CalculateLectureTimeParams(content: widget.content),
    );
  }

  Future<void> _submitArticle() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      print('Iniciando proceso de subida del artículo...');
      
      // Subir imagen a Firebase Storage
      final storageService = sl<FirebaseStorageService>();
      final fileName = 'article_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('Subiendo imagen: $fileName');
      final imageUrl = await storageService.uploadImage(widget.image, fileName);
      print('Imagen subida exitosamente: $imageUrl');

      // Calcular tiempo de lectura
      print('Calculando tiempo de lectura...');
      final lectureTime = await _calculateReadingTime();
      print('Tiempo de lectura calculado: $lectureTime minutos');

      // Usar la descripción proporcionada por el usuario
      print('Usando descripción del usuario...');
      final description = widget.description;
      print('Descripción del usuario: $description');

      // Crear artículo con la URL de la imagen subida
      print('Creando entidad del artículo...');
      final article = ArticleEntity(
        title: widget.title.trim(),
        author: 'David',
        description: description,
        content: widget.content.trim(),
        url: null,
        urlToImage: imageUrl,
        source: 'DNews',
        lectureTime: lectureTime,
      );
      
      print('Artículo creado con source: ${article.source} y lectureTime: ${article.lectureTime}');

      // Enviar evento al bloc
      print('Enviando evento UploadArticle al bloc...');
      context.read<UploadArticleBloc>().add(UploadArticle(article: article));
      
      print('Proceso de subida completado exitosamente');
    } catch (e) {
      print('Error durante la subida: $e');
      setState(() {
        _isUploadingImage = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


}
