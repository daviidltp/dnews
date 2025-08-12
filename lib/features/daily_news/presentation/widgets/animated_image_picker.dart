import 'dart:io';
import 'package:flutter/material.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';

class AnimatedImagePicker extends StatefulWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  final Widget? placeholder;
  final bool enableAnimation;
  final bool isClickable;

  const AnimatedImagePicker({
    super.key,
    required this.selectedImage,
    required this.onTap,
    this.placeholder,
    this.enableAnimation = true,
    this.isClickable = true,
  });

  @override
  State<AnimatedImagePicker> createState() => _AnimatedImagePickerState();
}

class _AnimatedImagePickerState extends State<AnimatedImagePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    // Solo animar si está clickeable y la animación está habilitada
    if (widget.isClickable && widget.enableAnimation) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    // No revertir inmediatamente, esperar a que termine la acción
  }

  void _onTapCancel() {
    _resetAnimation();
  }

  void _onTap() async {
    // Siempre cerrar el teclado al tocar
    FocusScope.of(context).unfocus();
    
    // Solo ejecutar la acción si está clickeable
    if (!widget.isClickable) return;
    
    // Ejecutar la acción
    widget.onTap();
    
    // Esperar un poco para que se vea la animación y luego resetear
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _resetAnimation();
    }
  }

  void _resetAnimation() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.53; // Misma altura que featured article
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: _onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: imageHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                ),
                  child: widget.selectedImage != null
                      ? Image.file(
                          widget.selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : widget.placeholder ?? _buildDefaultPlaceholder(),
                ),
              
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Toca para seleccionar una imagen',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Formato vertical recomendado',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
