// keyboard_event.dart

import 'package:flutter/material.dart';

abstract class KeyboardEvent {}

class KeyPressedEvent extends KeyboardEvent {
  final String key;
  final TextEditingController controller;

  KeyPressedEvent(this.key, this.controller); // El evento de presionar una tecla, se pasa la tecla presionada
}

class BackspacePressedEvent extends KeyboardEvent {
  final TextEditingController controller;
  BackspacePressedEvent(this.controller); // Evento para la tecla de borrado (backspace)
}

class ConfirmPressedEvent extends KeyboardEvent {
  final TextEditingController controller;
  ConfirmPressedEvent(this.controller); // Evento para la tecla de confirmación (Enter)
}
