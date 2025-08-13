import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:symmetry_showcase/features/daily_news/domain/entities/article.dart';

class CategorySelectionState {
  final List<ArticleCategory> selectedCategories;
  final int selectedIndex;

  const CategorySelectionState({
    required this.selectedCategories,
    required this.selectedIndex,
  });

  CategorySelectionState copyWith({
    List<ArticleCategory>? selectedCategories,
    int? selectedIndex,
  }) {
    return CategorySelectionState(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class CategorySelectionCubit extends Cubit<CategorySelectionState> {
  // Mapeo de índices a categorías
  static const Map<int, List<ArticleCategory>> _categoryMap = {
    0: [ArticleCategory.general, ArticleCategory.dnews], // General incluye tanto general como DNews
    1: [ArticleCategory.business],
    2: [ArticleCategory.sports], 
    3: [ArticleCategory.science],
    4: [ArticleCategory.technology],
    5: [ArticleCategory.dnews], // Solo DNews
  };

  CategorySelectionCubit() : super(const CategorySelectionState(
    selectedCategories: [ArticleCategory.general, ArticleCategory.dnews],
    selectedIndex: 0,
  ));

  void selectCategory(int index) {
    final categories = _categoryMap[index] ?? [ArticleCategory.general];
    emit(state.copyWith(
      selectedCategories: categories,
      selectedIndex: index,
    ));
  }

  List<ArticleCategory> getCategoriesForIndex(int index) {
    return _categoryMap[index] ?? [ArticleCategory.general];
  }

  static const List<String> categoryNames = [
    'General',
    'Business', 
    'Sports',
    'Science',
    'Technology',
    'DNews',
  ];
}
