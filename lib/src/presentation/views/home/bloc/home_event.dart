part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}


class HomeLoadData extends HomeEvent {
}

class AppVersionEvent extends HomeEvent {
  final BuildContext context;
  AppVersionEvent(this.context);
}

class ClearDataEvent extends HomeEvent {
}