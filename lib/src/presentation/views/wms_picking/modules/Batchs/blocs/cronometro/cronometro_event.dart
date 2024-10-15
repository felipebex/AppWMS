part of 'cronometro_bloc.dart';

@immutable
sealed class CronometroEvent {}


class StartCronometroEvent extends CronometroEvent {
  StartCronometroEvent();
}

class StopCronometroEvent extends CronometroEvent {
  StopCronometroEvent();
}