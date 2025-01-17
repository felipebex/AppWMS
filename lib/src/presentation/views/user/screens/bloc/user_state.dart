part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class ConfigurationLoaded extends UserState {
  final Configurations configurations;

  ConfigurationLoaded(this.configurations);
}

final class ConfigurationLoadedUser extends UserState {
  final Configurations configurations;

  ConfigurationLoadedUser(this.configurations);
}


final class ConfigurationError extends UserState {
  final String message;

  ConfigurationError(this.message);
}

final class ConfigurationLoading extends UserState {}


final class LoadInfoDeviceStateUser extends UserState {

}