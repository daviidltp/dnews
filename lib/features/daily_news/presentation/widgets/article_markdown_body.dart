import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';

class ArticleMarkdownBody extends StatelessWidget {
  final String data;
  final double? blockquoteBorderWidth;

  const ArticleMarkdownBody({
    super.key,
    required this.data,
    this.blockquoteBorderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
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
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.textPrimary.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.textPrimary.withOpacity(0.3),
              width: blockquoteBorderWidth ?? 2,
            ),
          ),
        ),
      ),
    );
  }
}
