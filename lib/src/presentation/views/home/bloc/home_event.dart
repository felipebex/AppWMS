part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}


class HomeLoadEvent extends HomeEvent {
  final BuildContext context;
  HomeLoadEvent(
    this.context,
  );
}