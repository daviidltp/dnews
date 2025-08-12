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

  void _showMarkdownHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Guía de Markdown',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMarkdownExample('**Texto en negrita**', 'Texto en negrita'),
              _buildMarkdownExample('*Texto en cursiva*', 'Texto en cursiva'),
              _buildMarkdownExample('`código`', 'código'),
              _buildMarkdownExample('[enlace](https://ejemplo.com)', 'enlace'),
              _buildMarkdownExample('# Título grande', 'Título grande'),
              _buildMarkdownExample('## Título mediano', 'Título mediano'),
              _buildMarkdownExample('- Elemento de lista', '• Elemento de lista'),
              _buildMarkdownExample('> Cita', 'Cita'),
              const SizedBox(height: 8),
              const Text(
                'Código en bloque:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '```\ncódigo aquí\n```',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownExample(String markdown, String result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              markdown,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              result,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
