part of 'transfer_info_bloc.dart';

@immutable
sealed class TransferInfoEvent {}

class UpdateScannedValueEventTransfer extends TransferInfoEvent {
  final String scannedValue;
  final String scan;
  UpdateScannedValueEventTransfer(this.scannedValue, this.scan);
}

class ClearScannedValueEventTransfer extends TransferInfoEvent {
  final String scan;
  ClearScannedValueEventTransfer(this.scan);
}

class LoadLocationsTransfer extends TransferInfoEvent {}

class ValidateFieldsEventTransfer extends TransferInfoEvent {
  final String field;
  final bool isOk;
  ValidateFieldsEventTransfer({required this.field, required this.isOk});
}



class ChangeLocationDestIsOkEventTransfer extends TransferInfoEvent {
  final bool locationDestIsOk;
  final ResultUbicaciones location;
  ChangeLocationDestIsOkEventTransfer(this.locationDestIsOk,  this.location);
}




class SendTransferInfo extends TransferInfoEvent{
final dynamic quantity;
final TransferInfoRequest request;
SendTransferInfo(this.request, this.quantity);
}




class ShowKeyboardEvent extends TransferInfoEvent {
  final bool showKeyboard;
  ShowKeyboardEvent(this.showKeyboard);
}


class SearchLocationEvent extends TransferInfoEvent {
  final String query;

  SearchLocationEvent(
    this.query,
  );
}
