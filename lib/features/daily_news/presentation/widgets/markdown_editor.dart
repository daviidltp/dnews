import 'package:flutter/material.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';

class MarkdownEditor extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const MarkdownEditor({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Content editor
          Container(
            constraints: const BoxConstraints(minHeight: 250),
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: controller,
              maxLines: null,
              minLines: 12,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Escribe tu artículo aquí...\n\nPuedes usar Markdown:\n**negrita**, *cursiva*, [enlaces](url), `código`, etc.',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
