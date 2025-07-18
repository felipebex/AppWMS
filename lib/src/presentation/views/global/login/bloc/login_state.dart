part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}


//estados para el login

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {}

final class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}

class PasswordVisibilityToggled extends LoginState {
   PasswordVisibilityToggled(bool isVisible);
}