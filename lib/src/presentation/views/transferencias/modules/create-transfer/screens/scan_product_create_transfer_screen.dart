import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';

class CreateTransferScreen extends StatelessWidget {
  const CreateTransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: white,
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColorApp,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              width: double.infinity,
              child: BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                  builder: (context, status) {
                return Column(
                  children: [
                    const WarningWidgetCubit(),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 0,
                          top: status != ConnectionStatus.online ? 0 : 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: white),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                'transferencias',
                              );
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: size.width * 0.12),
                            child: const Text("CREAR TRANSFERENCIA",
                                style: TextStyle(color: white, fontSize: 18)),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ));
  }
}
