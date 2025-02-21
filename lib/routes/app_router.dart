// app_routes.dart

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/user/screens/user_screen.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/packing_detail.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/screens/packing_list.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_detail.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_screen.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/history/screens/history_detail_screen.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/history/screens/list_batchs_history_screen.dart';

class AppRoutes {
  // Mapa estático de rutas
  static const String enterprice = 'enterprice';
  static const String auth = 'auth';
  static const String checkout = 'checkout';

  // WMS Picking
  static const String wmsPicking = 'wms-picking';
  static const String batch = 'batch';
  static const String batchDetail = 'batch-detail';
  static const String historyLits = 'history-list';
  static const String historyDetail = 'history-detail';

  // WMS Packing
  static const String wmsPacking = 'wms-packing';
  static const String packingList = 'packing-list';
  static const String packing = 'Packing';
  static const String packingDetail = 'packing-detail';

  // Otros
  static const String yms = 'yms';
  static const String counter = 'counter';
  static const String home = 'home';
  static const String ventor = 'ventor';
  static const String user = 'user';
  // static const String print = 'print';

  // Mapa de rutas
  static Map<String, Widget Function(BuildContext)> get routes {
    return {
      // Global
      enterprice: (_) => const SelectEnterpricePage(),
      auth: (_) => const LoginPage(),
      checkout: (_) => const CheckAuthPage(),

      // WMS Picking
      wmsPicking: (context) => WMSPickingPage(
            indexSelected: ModalRoute.of(context)!.settings.arguments as int,
          ),
      batch: (_) => const BatchScreen(),
      batchDetail: (_) => const BatchDetailScreen(),
      historyLits: (_) => const HistoryListScreen(),
      historyDetail: (_) => const HistoryDetailScreen(),

      // WMS Packing
      wmsPacking: (_) => const WmsPackingScreen(),

      packingList: (context) {
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        final batchModel = arguments[0] as BatchPackingModel?;
        return PakingListScreen(
          batchModel: batchModel,
        );
      },

      packing: (context) {
        // Obtener los argumentos (una lista)
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final packingModel = arguments[0] as PedidoPacking?;
        final batchModel = arguments[1] as BatchPackingModel?;

        return PackingScreen(
          packingModel: packingModel,
          batchModel: batchModel,
        );
      },

      packingDetail: (context) {
        // Obtener los argumentos (una lista)
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final packingModel = arguments[0] as PedidoPacking?;
        final batchModel = arguments[1] as BatchPackingModel?;

        return PackingDetailScreen(
          packingModel: packingModel,
          batchModel: batchModel,
        );
      },

      // Otros
      yms: (_) => const YMSPage(),
      counter: (_) => const CounterPage(),
      home: (_) => const HomePage(),
      ventor: (_) => const VentorHome(),
      user: (_) => const UserScreen(),
      // print: (_) => const PrintScreen(),
    };
  }
}
