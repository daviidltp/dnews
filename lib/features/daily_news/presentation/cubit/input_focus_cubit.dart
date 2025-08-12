import 'package:flutter_bloc/flutter_bloc.dart';

class InputFocusCubit extends Cubit<bool> {
  InputFocusCubit() : super(false);

  void updateFocusState({
    required bool titleFocused,
    required bool descriptionFocused,
    required bool contentFocused,
  }) {
    final isAnyInputFocused = titleFocused || descriptionFocused || contentFocused;
    emit(isAnyInputFocused);
  }
}
