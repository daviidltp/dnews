import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/pages/upload/preview_article.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/widgets/animated_image_picker.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/cubit/input_focus_cubit.dart';

class UploadArticlePage extends StatefulWidget {
  const UploadArticlePage({super.key});

  @override
  State<UploadArticlePage> createState() => _UploadArticlePageState();
}

class _UploadArticlePageState extends State<UploadArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  
  // Focus nodes para detectar cuando los inputs están enfocados
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _contentFocus = FocusNode();
  
  // Cubit para el manejo de focus
  late InputFocusCubit _inputFocusCubit;
  
  // Variables para validar si los campos están completos
  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty &&
           _descriptionController.text.trim().isNotEmpty &&
           _contentController.text.trim().isNotEmpty &&
           _selectedImage != null;
  }

    @override
  void initState() {
    super.initState();
    _inputFocusCubit = InputFocusCubit();
    
    // Escuchar cambios en los controladores para actualizar el estado del botón
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _contentController.addListener(_onFormChanged);
    
    // Escuchar cambios de focus
    _titleFocus.addListener(_onFocusChanged);
    _descriptionFocus.addListener(_onFocusChanged);
    _contentFocus.addListener(_onFocusChanged);
  }
  
  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _contentController.removeListener(_onFormChanged);
    
    _titleFocus.removeListener(_onFocusChanged);
    _descriptionFocus.removeListener(_onFocusChanged);
    _contentFocus.removeListener(_onFocusChanged);
    
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _contentFocus.dispose();
    
    _inputFocusCubit.close();
    
    super.dispose();
  }
  
  void _onFormChanged() {
    setState(() {
      // Actualizar el estado para habilitar/deshabilitar el botón
    });
  }
  
  void _onFocusChanged() {
    _inputFocusCubit.updateFocusState(
      titleFocused: _titleFocus.hasFocus,
      descriptionFocused: _descriptionFocus.hasFocus,
      contentFocused: _contentFocus.hasFocus,
    );
  }

    @override
  Widget build(BuildContext context) {
     
    return BlocProvider<InputFocusCubit>.value(
      value: _inputFocusCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildCustomAppBar(),
        body: GestureDetector(
          onTap: () {
            // Quitar el foco cuando se toca fuera de los inputs
            FocusScope.of(context).unfocus();
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image picker
                  _buildImagePicker(),
                  // Title and content editor
                  _buildTitleAndContentEditor(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Material(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 48,
              height: 48,
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
      ),
      actions: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isFormValid ? _goToPreview : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _isFormValid ? Colors.white : Colors.white.withOpacity(0.3),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: _isFormValid ? Colors.blue : Colors.blue.withOpacity(0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTitleAndContentEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description inputs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                maxLength: 100,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title of the article',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Merriweather',
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  alignLabelWithHint: true,
                  isCollapsed: true,
                  counterText: '',
                ),
                textAlignVertical: TextAlignVertical.top,
                maxLines: null,
              ),
              SizedBox(height: 16),
              // Description input
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                maxLength: 100,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Merriweather',
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  hintText: 'Add a description',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Merriweather',
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  alignLabelWithHint: true,
                  isCollapsed: true,
                  counterText: '',
                ),
                textAlignVertical: TextAlignVertical.top,
                maxLines: null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),        // Content input without margin
        const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20), 
                      child: Divider(height: 1, color: AppColors.borderLight),
                    ),
        TextFormField(
             controller: _contentController,
             focusNode: _contentFocus,
             style: const TextStyle(
               fontSize: 16,
               color: AppColors.textPrimary,
               fontFamily: 'Merriweather',
               height: 1.5,
             ),
             decoration: const InputDecoration(
               hintText: 'Write here your article (Markdown Supported)',
               hintStyle: TextStyle(
                 fontSize: 16,
                 color: AppColors.textSecondary,
                 height: 1.5,
               ),
               border: InputBorder.none,
               contentPadding: EdgeInsets.all(16),
             ),
             maxLines: null,
             minLines: 10,
           ),
        
      ],
    );
  }





  Widget _buildImagePicker() {
    return BlocBuilder<InputFocusCubit, bool>(
      builder: (context, isAnyInputFocused) {
        return AnimatedImagePicker(
          selectedImage: _selectedImage,
          onTap: _handleImagePickerTap,
          isClickable: !isAnyInputFocused,
        );
      },
    );
  }



  void _handleImagePickerTap() {
    // El AnimatedImagePicker ya se encarga de cerrar el teclado
    // Solo proceder con seleccionar imagen
    _pickImage();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _onFormChanged(); // Actualizar el estado del botón
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> _goToPreview() async {
    if (_isFormValid) {
      // Navegar a la vista previa
      FocusManager.instance.primaryFocus?.unfocus(); 
      final result = await Navigator.of(context).push<bool>(
        CupertinoPageRoute(
          builder: (context) => PreviewArticlePage(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            content: _contentController.text.trim(),
            image: _selectedImage!,
          ),
        ),
      );
      
      // Si el artículo se subió exitosamente, regresar true para activar la recarga
      if (result == true && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}
