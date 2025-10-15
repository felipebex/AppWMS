import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'crate_transfer_event.dart';
part 'crate_transfer_state.dart';

class CrateTransferBloc extends Bloc<CrateTransferEvent, CrateTransferState> {
  CrateTransferBloc() : super(CrateTransferInitial()) {
    on<CrateTransferEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
