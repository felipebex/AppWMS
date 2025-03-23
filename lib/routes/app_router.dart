// app_routes.dart

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/list_ordernes_compra_screen.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/scan_product_screen.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/widgets/others/new_lote_widget.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/screens/list_transferencias_screen.dart';
import 'package:wms_app/src/presentation/views/transferencias/screens/scan_product_transfer_screen.dart';
import 'package:wms_app/src/presentation/views/transferencias/screens/transferencia_screen.dart';
import 'package:wms_app/src/presentation/views/user/screens/user_screen.dart';
import 'package:wms_app/src/presentation/views/wms_packing/models/packing_response_model.dart';
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

  //inventario
  static const String inventario = 'inventario';

  //transferencias
  static const String transferencias = 'transferencias';
  static const String transferenciaDetail = 'transferencia-detail';

  // Global
  static const String home = 'home';
  static const String user = 'user';

  // Operaciones
  static const String recepcion = 'recepcion';
  static const String listOrdenesCompra = 'list-ordenes-compra';
  static const String scanProductOrder = 'scan-product-order';
  static const String scanProductTransfer = 'scan-product-transfer';

  //new lote
  static const String newLote = 'new-lote';

  //info rapida
  static const String infoRapida = 'info-rapida';

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
        final initialTabIndex = arguments[2] as int;

        return PackingDetailScreen(
          packingModel: packingModel,
          batchModel: batchModel,
          initialTabIndex: initialTabIndex,
        );
      },

      // global
      home: (_) => const HomePage(),
      user: (_) => const UserScreen(),

      // inventario
      inventario: (_) => const InventarioScreen(),
      // Operaciones

      scanProductOrder: (context) {
        // Obtener los argumentos (una lista)
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final ordenCompraArg = arguments[0] as ResultEntrada?;
        final currentProducArg = arguments[1] as LineasTransferencia?;

        return ScanProductOrderScreen(
            ordenCompra: ordenCompraArg, currentProduct: currentProducArg);
      },

      scanProductTransfer: (context) {
        // Obtener los argumentos (una lista)
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final transfer = arguments[0] as ResultTransFerencias?;
        final currentProducArg = arguments[1] as LineasTransferenciaTrans?;

        return ScanProductTrasnferScreen(
            transfer: transfer, currentProduct: currentProducArg);
      },

      recepcion: (context) {
        // Obtener los argumentos (una lista)
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        // Asegurarnos de que la lista tenga al menos dos elementos
        final ordenCompraArg = arguments[0] as ResultEntrada?;
        final initialTabIndexArg = arguments[1] as int?;
        return RecepcionScreen(
            ordenCompra: ordenCompraArg,
            initialTabIndex: initialTabIndexArg ?? 0);
      },

      listOrdenesCompra: (_) => const ListOrdenesCompraScreen(),
      newLote: (context) {
        // Obtener los argumentos (una lista)
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final ordenCompraArg = arguments[0] as ResultEntrada?;
        final currentProducArg = arguments[1] as LineasTransferencia?;

        return NewLoteScreen(
            ordenCompra: ordenCompraArg, currentProduct: currentProducArg);
      },

      //info rapida
      infoRapida: (_) => const InfoRapidaScreen(),
      //transferencias
      transferencias: (_) => const ListTransferenciasScreen(),
      transferenciaDetail: (context) {
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final transferencia = arguments[0] as ResultTransFerencias?;
        final initialTabIndexArg = arguments[1] as int?;

        return TransferenciaScreen(
          transferencia: transferencia,
          initialTabIndex: initialTabIndexArg ?? 0,
        );
      },
    };
  }
}
