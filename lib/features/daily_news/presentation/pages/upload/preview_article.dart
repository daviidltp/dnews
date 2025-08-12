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
              'Vista previa',
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
    return AnimatedImagePicker(
      selectedImage: widget.image,
      onTap: () {}, // Sin acción en preview
      enableAnimation: false, // Sin animación en preview
    );
  }

  Widget _buildArticlePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          // Author and reading time info
          Row(
            children: [
              const Text(
                'Por David',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
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
                      '${snapshot.data} min de lectura',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    );
                  }
                  return const Text(
                    'Calculando...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  );
                },
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
                height: 1.6,
              ),
              h1: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              h2: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              h3: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              strong: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              em: const TextStyle(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
              code: TextStyle(
                backgroundColor: AppColors.surface,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              codeblockDecoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              blockquote: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
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
      // Subir imagen a Firebase Storage
      final storageService = sl<FirebaseStorageService>();
      final fileName = 'article_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await storageService.uploadImage(widget.image, fileName);

      // Calcular tiempo de lectura
      final lectureTime = await _calculateReadingTime();

      // Generar descripción automática desde las primeras líneas del contenido
      final description = _generateDescription(widget.content);

      // Crear artículo con la URL de la imagen subida
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

      context.read<UploadArticleBloc>().add(UploadArticle(article: article));
    } catch (e) {
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

  String _generateDescription(String content) {
    // Remover markdown básico para la descripción
    String cleanContent = content
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // negrita
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // cursiva
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // código
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // enlaces
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '') // headers
        .replaceAll(RegExp(r'\n{2,}'), ' ') // múltiples saltos de línea
        .trim();

    // Tomar las primeras 150 caracteres aproximadamente
    if (cleanContent.length <= 150) {
      return cleanContent;
    }

    // Buscar el último espacio antes del límite para no cortar palabras
    final cutIndex = cleanContent.lastIndexOf(' ', 147);
    return cutIndex != -1 
        ? '${cleanContent.substring(0, cutIndex)}...'
        : '${cleanContent.substring(0, 147)}...';
  }
}
