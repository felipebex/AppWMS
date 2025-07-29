part of 'conteo_bloc.dart';

@immutable
sealed class ConteoState {}

final class ConteoInitial extends ConteoState {}


class ConteoLoading extends ConteoState {}

final class ConteoLoaded extends ConteoState {
  final List<DatumConteo> conteos;

  ConteoLoaded(this.conteos);
}

final class ConteoError extends ConteoState {
  final String message;

  ConteoError(this.message);
}

class LoadConteoSuccess extends ConteoState {
  final DatumConteo ordenConteo;
  LoadConteoSuccess(this.ordenConteo);
}


//estados para cargar la lista de conteos desde la bd
class ConteoFromDBLoaded extends ConteoState {
  final List<DatumConteo> conteos;

  ConteoFromDBLoaded(this.conteos);
}

class ConteoFromDBLoading extends ConteoState {}

class ConteoFromDBError extends ConteoState {
  final String message;

  ConteoFromDBError(this.message);
}


