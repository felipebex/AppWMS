part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}


final class HomeLoadingState extends HomeState {}

final class HomeLoadErrorState extends HomeState {}

final class HomeLoadedState extends HomeState {
}


///estados de carga de la version de la app

final class AppVersionLoadingState extends HomeState {}

final class AppVersionLoadErrorState extends HomeState {
  final String message;

  AppVersionLoadErrorState(this.message);
}

final class AppVersionLoadedState extends HomeState {
  final AppVersion version;

  AppVersionLoadedState(this.version);
}

final class AppVersionUpdateState extends HomeState {
  final AppVersion version;
  AppVersionUpdateState(this.version);
}