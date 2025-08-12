import 'package:flutter/material.dart';

class ResizingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;
  final Color? shadowColor;
  final double resizeScale;
  final Duration animationDuration;

  const ResizingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.resizeScale = 0.95,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  State<ResizingButton> createState() => _ResizingButtonState();
}

class _ResizingButtonState extends State<ResizingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.resizeScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    // Solo revertir si no hay onPressed o si se ejecutó el tap
    _resetButton();
  }

  void _onTapCancel() {
    _resetButton();
  }

  void _resetButton() {
    _animationController.reverse();
  }

  void _onTap() async {
    if (widget.onPressed != null) {
      // Esperar un poco para que se vea la animación de hundimiento
      await Future.delayed(const Duration(milliseconds: 80));
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ocupa todo el ancho disponible
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                  boxShadow: widget.elevation != null && widget.elevation! > 0
                      ? [
                          BoxShadow(
                            color: widget.shadowColor?.withOpacity(0.3) ??
                                Colors.black.withOpacity(0.2),
                            blurRadius: widget.elevation! * 2,
                            offset: Offset(0, widget.elevation! / 2),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: widget.foregroundColor ?? Colors.white,
                      ),
                      child: Center(child: widget.child), // Centrar el contenido
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
