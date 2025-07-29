part of 'conteo_bloc.dart';

@immutable
sealed class ConteoEvent {}

class GetConteosEvent extends ConteoEvent {}

class GetConteosFromDBEvent extends ConteoEvent {}


class LoadConteoAndProductsEvent extends ConteoEvent {

  final int ordenConteoId;

  LoadConteoAndProductsEvent({required this.ordenConteoId});

}