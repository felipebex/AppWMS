part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final BuildContext context;

  LoginButtonPressed(this.context);
}
