import 'package:flutter_bloc/flutter_bloc.dart';

class ButtonSelectionCubit extends Cubit<int> {
  ButtonSelectionCubit() : super(0); // 0 = primer botón seleccionado por defecto

  void selectButton(int index) {
    emit(index);
  }
}
