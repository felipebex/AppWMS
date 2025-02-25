// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/tabs/tab1.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/tabs/tab3.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/tabs/tab2.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/tabs/tab4.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
class PackingDetailScreen extends StatefulWidget {
  const PackingDetailScreen({
    super.key,
    required this.packingModel,
    this.batchModel,
    this.initialTabIndex = 0, // Valor por defecto es 0
  });

  final PedidoPacking? packingModel;
  final BatchPackingModel? batchModel;
  final int initialTabIndex; // Nueva propiedad para la posición inicial

  @override
  State<PackingDetailScreen> createState() => _PackingDetailScreenState();
}

class _PackingDetailScreenState extends State<PackingDetailScreen>
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
    return BlocConsumer<WmsPackingBloc, WmsPackingState>(
      listener: (context, state) {},
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  context.read<WmsPackingBloc>().listOfProductsForPacking.clear();
                  context.read<WmsPackingBloc>().add(
                        LoadAllPedidosFromBatchEvent(
                          widget.packingModel?.batchId ?? 0,
                        ),
                      );
                  Navigator.pushReplacementNamed(
                    context,
                    'packing-list',
                    arguments: [widget.batchModel],
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
            body: TabBarView(
              controller: _tabController, // Asignar el TabController
              children: [
                Tab1Screen(
                  size: size,
                  packingModel: widget.packingModel ?? PedidoPacking(),
                  batchModel: widget.batchModel ?? BatchPackingModel(),
                ),
                Tab2Screen(
                  packingModel: widget.packingModel ?? PedidoPacking(),
                  batchModel: widget.batchModel ?? BatchPackingModel(),
                ),
                const Tab3Screen(),
                const Tab4Screen(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DialogNewPackage extends StatelessWidget {
  const DialogNewPackage({super.key, required this.onPackageAdded});

  final Function(String) onPackageAdded;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        title:  Center(
          child: Text(
            'Agregar empaque',
            style: TextStyle(
              color: primaryColorApp,
              fontSize: 18,
            ),
          ),
        ),
        content: const SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de agregar un empaque?',
                style: TextStyle(color: black),
              ),
              SizedBox(height: 10),
              // Puedes agregar más detalles aquí si es necesario
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí se agrega un nuevo empaque
              onPackageAdded('Nuevo Paquete'); // Cambia esto según tu lógica
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColorApp,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Aceptar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
