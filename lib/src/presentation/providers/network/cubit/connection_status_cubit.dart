import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wms_app/main.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';

class ConnectionStatusCubit extends Cubit<ConnectionStatus> {
  late StreamSubscription _connectionSubscription;

  ConnectionStatusCubit() : super(ConnectionStatus.online) {
    _connectionSubscription = internetChecker.internetStatus().listen(emit);
  }

  @override
  Future<void> close() {
    _connectionSubscription.cancel();
    return super.close();
  }
}