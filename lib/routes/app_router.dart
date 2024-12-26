// app_routes.dart

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/user/screens/user_screen.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/packing_detail.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/packing_list.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_detail.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_screen.dart';


class AppRoutes {
  // Mapa estático de rutas
  static const String enterprice = 'enterprice';
  static const String auth = 'auth';
  static const String checkout = 'checkout';

  // WMS Picking
  static const String wmsPicking = 'wms-picking';
  static const String batch = 'batch';
  static const String batchDetail = 'batch-detail';

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

      // WMS Packing
      wmsPacking: (_) => const WmsPackingScreen(),
      packingList: (context) => PakingListScreen(
        batchModel: ModalRoute.of(context)!.settings.arguments as BatchPackingModel?,
      ),
      packing: (_) => const PackingScreen(),
      packingDetail: (context) => PackingDetailScreen(
        packingModel: ModalRoute.of(context)!.settings.arguments as PedidoPacking?,
      ),

      // Otros
      yms: (_) => const YMSPage(),
      counter: (_) => const CounterPage(),
      home: (_) => const HomePage(),
      ventor: (_) => const VentorHome(),
      user: (_) => const UserScreen(),
    };
  }
}
