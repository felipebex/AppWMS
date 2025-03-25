// ignore_for_file: must_be_immutable

part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

final class GetConfigurations extends UserEvent {

    BuildContext context;
    GetConfigurations(this.context);
}

final class GetConfigurationsFromDB extends UserEvent {}


final class LoadInfoDeviceEventUser extends UserEvent {}


final class GetUbicacionesEvent   extends UserEvent {
}