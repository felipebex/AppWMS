import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';

class ConnectionStatusCubit extends Cubit<ConnectionStatus> {
  final CheckInternetConnection internetChecker;
  late final StreamSubscription _subscription;

  ConnectionStatusCubit({required this.internetChecker}) : super(ConnectionStatus.online) {
    _subscription = internetChecker.internetStatus().listen(emit);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    super.close();
  }
}
