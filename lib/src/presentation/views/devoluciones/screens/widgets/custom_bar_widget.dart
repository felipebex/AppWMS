
// CustomAppBar permanece igual
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
      builder: (context, status) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColorApp,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const WarningWidgetCubit(),
              Padding(
                padding: EdgeInsets.only(
                  top: status != ConnectionStatus.online ? 0 : 30,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: white),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.15),
                      child: const Text(
                        "NUEVA DEVOLUCION",
                        style: TextStyle(color: white, fontSize: 18),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
