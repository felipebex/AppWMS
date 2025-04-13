// app_routes.dart

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/models/info_rapida_model.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/quick%20info/locations_info_screen.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/quick%20info/product_info_screen.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/transfer/transfer_info_screen.dart';
import 'package:wms_app/src/presentation/views/inventario/models/response_products_model.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/widgets/location/location_search_widget.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/widgets/new_lote_widget.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/widgets/product/product_search_widget.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/list_ordernes_compra_screen.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/scan_product_screen.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/widgets/locations_dest/locations_dest_widget.dart';
import 'package:wms_app/src/presentation/views/recepcion/screens/widgets/others/new_lote_widget.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-externa/transfer_externa_screen.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-externa/widgets/location/location_search_widget.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-externa/widgets/product/product_search_widget.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/screens/list_transferencias_screen.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/screens/scan_product_transfer_screen.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/screens/transferencia_screen.dart';
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
  static const String searchLocation = 'search-location';
  static const String searchProduct = 'search-product';
  static const String newLoteInventario = 'new-lote-inventario';

  //transferencias
  static const String transferencias = 'transferencias';
  static const String transferenciaDetail = 'transferencia-detail';
  static const String transferExterna = 'transfer-externa';
  static const String searchProductTrans = 'search-product-trans';
  static const String searchLocationTrans = 'search-location-trans';

  // Global
  static const String home = 'home';
  static const String user = 'user';

  // Operaciones
  static const String recepcion = 'recepcion';
  static const String listOrdenesCompra = 'list-ordenes-compra';
  static const String scanProductOrder = 'scan-product-order';
  static const String locationDestSearch = 'search-location-recep';

  static const String scanProductTransfer = 'scan-product-transfer';
  //new lote
  static const String newLote = 'new-lote';

  //info rapida
  static const String infoRapida = 'info-rapida';
  static const String productInfo = 'product-info';
  static const String locationInfo = 'location-info';
  static const String transferInfo = 'transfer-info';

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

      searchLocation: (_) => const SearchLocationScreen(),
      searchProduct: (_) => const SearchProductScreen(),
      newLoteInventario: (context) {
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final currentProduct = arguments[0] as Product?;

        return NewLoteInventarioScreen(
          currentProduct: currentProduct,
        );
      },

      //BUSCADOR UBICACION DESTINO
      locationDestSearch: (context) {
        // Obtener los argumentos (una lista)
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final ordenCompraArg = arguments[0] as ResultEntrada?;
        final currentProducArg = arguments[1] as LineasTransferencia?;

        return LocationDestRecepScreen(
            ordenCompra: ordenCompraArg, currentProduct: currentProducArg);
      },

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
        final currentProducArg = arguments[0] as LineasTransferenciaTrans?;

        return ScanProductTrasnferScreen(currentProduct: currentProducArg);
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
      productInfo: (context) {
        return ProductInfoScreen();
      },
      locationInfo: (context) {
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;

        // Asegurarnos de que la lista tenga al menos dos elementos
        final info = arguments[0] as InfoRapidaResult?;
        return LocationInfoScreen(
          infoRapidaResult: info,
        );
      },
      transferInfo: (context) {
        final arguments =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        // Asegurarnos de que la lista tenga al menos dos elementos
        final info = arguments[0] as InfoResult?;
        final ubi = arguments[1] as Ubicacion?;
        return TransferInfoScreen(
          infoRapidaResult: info,
          ubicacion: ubi,
        );
      },

      //transferencias
      transferencias: (_) {
        return ListTransferenciasScreen();
      },
      // transferExterna: (_) => const TransferExternaScreen(),
      searchProductTrans: (_) => const SearchLocationScreenTrans(),
      // searchLocationTrans: (_) => const SearchProductScreenTrans(),

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
