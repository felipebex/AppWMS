part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

final class GetConfigurations extends UserEvent {

    BuildContext context;
    GetConfigurations(this.context);
  
}

final class GetConfigurationsFromDB extends UserEvent {}