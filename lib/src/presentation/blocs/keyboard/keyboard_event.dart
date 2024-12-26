// keyboard_state.dart

abstract class KeyboardState {}

class KeyboardInitialState extends KeyboardState {}

class KeyboardUpdatedState extends KeyboardState {
  final String updatedText;

  KeyboardUpdatedState(this.updatedText); // Estado que contiene el texto actualizado
}
