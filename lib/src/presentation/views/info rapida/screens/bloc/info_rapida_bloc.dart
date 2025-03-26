import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'info_rapida_event.dart';
part 'info_rapida_state.dart';

class InfoRapidaBloc extends Bloc<InfoRapidaEvent, InfoRapidaState> {
  InfoRapidaBloc() : super(InfoRapidaInitial()) {
    on<InfoRapidaEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
