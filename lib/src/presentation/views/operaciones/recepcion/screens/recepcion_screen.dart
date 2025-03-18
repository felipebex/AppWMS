import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/tabs/tab1.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/tabs/tab2.dart';
import 'package:wms_app/src/presentation/views/operaciones/recepcion/screens/tabs/tab3.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class RecepcionScreen extends StatefulWidget {
  const RecepcionScreen({
    super.key,
    required this.ordenCompra,
    this.initialTabIndex = 0, // Valor por defecto es 0
  });

  final ResultEntrada? ordenCompra;
  final int initialTabIndex; // Nueva propiedad para la posición inicial

  @override
  State<RecepcionScreen> createState() => _RecepcionScreenState();
}

class _RecepcionScreenState extends State<RecepcionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inicializar el TabController con la longitud de las pestañas
    _tabController = TabController(
      length: 3,
      vsync: this,
     initialIndex: widget.initialTabIndex,  // Posición inicial
    );
  }

  @override
  void dispose() {
    _tabController.dispose(); // Desechar el TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            //volvemos a llamar las entradas que tenemos guardadas en la bd
            context.read<RecepcionBloc>().add(FetchOrdenesCompraOfBd(context));

            Navigator.pushReplacementNamed(
              context,
              'list-ordenes-compra',
            );
          },
        ),
        title: Text(
          'RECEPCIÓN',
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
                Tab1ScreenRecep(
                  ordenCompra: widget.ordenCompra,
                ),
                Tab2ScreenRecep(
                  ordenCompra: widget.ordenCompra,
                ),
                Tab3ScreenRecep(
                  ordenCompra: widget.ordenCompra,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
