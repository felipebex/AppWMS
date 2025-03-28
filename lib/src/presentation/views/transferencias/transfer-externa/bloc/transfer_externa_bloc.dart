import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'transfer_externa_event.dart';
part 'transfer_externa_state.dart';

class TransferExternaBloc extends Bloc<TransferExternaEvent, TransferExternaState> {
  TransferExternaBloc() : super(TransferExternaInitial()) {
    on<TransferExternaEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
