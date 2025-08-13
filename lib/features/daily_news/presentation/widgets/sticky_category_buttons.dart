import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/config/theme/app_themes.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/cubit/category_selection_cubit.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';

class StickyCategoryButtons extends StatelessWidget {
  const StickyCategoryButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyButtonsDelegate(),
    );
  }
}

class _StickyButtonsDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 50.0;

  @override
  double get maxExtent => 50.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      width: double.infinity,
      height: 52.0,
      color: Colors.white,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: BlocBuilder<CategorySelectionCubit, CategorySelectionState>(
            builder: (context, categoryState) {
              final categoryNames = CategorySelectionCubit.categoryNames;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoryNames.asMap().entries.map((entry) {
                    final index = entry.key;
                    final name = entry.value;
                    final isFirst = index == 0;
                    final isLast = index == categoryNames.length - 1;
                    return _buildSelectionButton(
                      context: context,
                      text: name,
                      index: index,
                      isSelected: categoryState.selectedIndex == index,
                      isFirst: isFirst,
                      isLast: isLast,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;

  Widget _buildSelectionButton({
    required BuildContext context,
    required String text,
    required int index,
    required bool isSelected,
    required bool isFirst,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: () {
        // Actualizar la selección de categoría
        context.read<CategorySelectionCubit>().selectCategory(index);
        
        // Obtener las categorías correspondientes y filtrar localmente
        final categories = context.read<CategorySelectionCubit>().getCategoriesForIndex(index);
        context.read<RemoteArticlesBloc>().add(FilterArticlesByCategories(categories));
      },
      child: Container(
          height: 40,
          width: text == 'Tecnología' ? 100 : 90, // Más ancho para "Tecnología"
          margin: EdgeInsets.only(
            right: isLast ? 24 : 12,
            left: isFirst ? 24 : 0,
          ),

          decoration: BoxDecoration(
            color: Colors.transparent,
            border: isSelected 
              ? const Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 3,
                  ),
                )
              : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.black : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    
  }
}
