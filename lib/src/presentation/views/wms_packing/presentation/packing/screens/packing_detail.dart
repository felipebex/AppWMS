// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/screens/tabs/tab3.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/screens/tabs/tab4.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/packing_pedido_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/tabs/tab1.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/tabs/tab2.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class PackingPedidoDetailScreen extends StatefulWidget {
  const PackingPedidoDetailScreen({
    super.key,
    this.initialTabIndex = 0, // Valor por defecto es 0
  });

  final int initialTabIndex; // Nueva propiedad para la posición inicial

  @override
  State<PackingPedidoDetailScreen> createState() => _PackingDetailScreenState();
}

class _PackingDetailScreenState extends State<PackingPedidoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inicializar el TabController con la longitud de las pestañas
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex, // Posición inicial
    );
  }

  @override
  void dispose() {
    _tabController.dispose(); // Desechar el TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return BlocConsumer<PackingPedidoBloc, PackingPedidoState>(
      listener: (context, state) {
        // if (state is WmsPackingErrorState) {
        //   Get.defaultDialog(
        //     title: '360 Software Informa',
        //     titleStyle: TextStyle(color: Colors.red, fontSize: 18),
        //     middleText: state.message,
        //     middleTextStyle: TextStyle(color: black, fontSize: 14),
        //     backgroundColor: Colors.white,
        //     radius: 10,
        //     actions: [
        //       ElevatedButton(
        //         onPressed: () {
        //           Get.back();
        //         },
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: primaryColorApp,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(10),
        //           ),
        //         ),
        //         child: Text('Aceptar', style: TextStyle(color: white)),
        //       ),
        //     ],
        //   );
        // }
        // if (state is WmsPackingSuccessState) {
        //   Get.snackbar(
        //     '360 Software Informa',
        //     state.message,
        //     backgroundColor: white,
        //     colorText: primaryColorApp,
        //     icon: Icon(Icons.error, color: Colors.green),
        //   );
        // }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
               
                  context.read<PackingPedidoBloc>().add(
                        LoadPackingPedidoFromDBEvent(),
                      );
                  Navigator.pushReplacementNamed(
                    context,
                    'list-packing',
                  );
                },
              ),
              title: const Text(
                'PACKING - DETAIL',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              bottom: TabBar(
                controller: _tabController, // Asignar el TabController
                indicatorWeight: 3,
                indicatorPadding: EdgeInsets.symmetric(vertical: 5),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(
                    text: 'Detalles',
                    icon: Icon(
                      Icons.details,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Tab(
                    text: 'Por hacer',
                    icon: Icon(
                      Icons.pending_actions,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Tab(
                    text: 'Preparado',
                    icon: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Tab(
                    text: 'Listo',
                    icon: Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
            body: Column(
              children: [
                const WarningWidgetCubit(isTop: false),
                Expanded(
                  child: TabBarView(
                    controller: _tabController, // Asignar el TabController
                    children: [
                      const Tab1PedidoScreen(),
                      const Tab2PedidoScreen(),
                      const Tab3Screen(),
                      const Tab4Screen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
