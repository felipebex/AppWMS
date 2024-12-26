part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}


final class HomeLoadingState extends HomeState {}

final class HomeLoadErrorState extends HomeState {}

final class HomeLoadedState extends HomeState {
}