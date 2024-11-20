import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class WarningWidgetCubit extends StatelessWidget {
  const WarningWidgetCubit({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectionStatusCubit(),
      child: BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
          builder: (context, status) {
        return Visibility(
          visible: status != ConnectionStatus.online,
          child: Container(
            padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
            height: 85,
            color: grey,
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: primaryColorApp, size: 30,),
                const SizedBox(width: 8),
                const Text('No hay conexión a internet',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
