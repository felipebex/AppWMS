// keyboard_bloc.dart

// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'keyboard_event.dart';
import 'keyboard_state.dart';

class KeyboardBloc extends Bloc<KeyboardEvent, KeyboardState> {

  KeyboardBloc() : super(KeyboardInitialState()) {
    // Manejador para el evento KeyPressedEvent
    on<KeyPressedEvent>((event, emit) {
      print("key pressed : ${event.key}");
      // Si la tecla presionada es un carácter, la agregamos al texto
      event.controller.
      text += event.key;
      print("controller text: ${event.controller.text}");
      emit(KeyboardUpdatedState(event.controller.text)); // Emitimos el estado con el texto actualizado
    });

    // Manejador para el evento BackspacePressedEvent
    on<BackspacePressedEvent>((event, emit) {
      print("backspace pressed");
      // Si presionamos backspace, borramos el último carácter
      if (event.controller.text.isNotEmpty) {
        event.controller.text = event.controller.text.substring(0, event.controller.text.length - 1);
      }
      emit(KeyboardUpdatedState(event.controller.text)); // Emitimos el estado con el texto actualizado
    });

    // Manejador para el evento ConfirmPressedEvent (Confirmación de acción)
    on<ConfirmPressedEvent>((event, emit) {
      print("confirm pressed");
      emit(KeyboardUpdatedState(event.controller.text)); // Emitimos el estado con el texto actualizado
    });
  }
}
