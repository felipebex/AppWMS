part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final BuildContext context;

  LoginButtonPressed(this.context);
}

// Evento para cambiar la visibilidad del texto en el campo de contraseña
class TogglePasswordVisibility extends LoginEvent {}