// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_print

import 'dart:io';
import 'package:cron/cron.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:wms_app/firebase_options.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/routes/app_router.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/api/http_response_handler.dart';
import 'package:wms_app/src/core/utils/formats_utils.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/core/utils/widgets/error_widget.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_bloc.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/bloc/devoluciones_bloc.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/modules/quick%20info/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/modules/transfer/bloc/transfer_info_bloc.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/bloc/inventario_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/batchs/bloc/recepcion_batch_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/data/transferencias_repository.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/requets_transfer_model.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/create-transfer/bloc/crate_transfer_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/packing_pedido_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_repository.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/item_picking_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wms_app/src/services/webSocket_service.dart';
import 'src/presentation/views/home/index.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // <--- NUEVA IMPORTACIÓN
import 'dart:async';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ApiRequestService apiRequestService = ApiRequestService();

// ✅ Instancias únicas
final internetChecker = CheckInternetConnection();
final connectionStatusCubit =
    ConnectionStatusCubit(internetChecker: internetChecker);
void main() async {
  // 1. **SIEMPRE LO PRIMERO:** Inicializar los bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. **ATRAPAR ERRORES:** Envolvemos la inicialización en runZonedGuarded
  await runZonedGuarded<Future<void>>(() async {
    // 3. **CONFIGURACIONES CRÍTICAS DEL FRAMEWORK DENTRO DE LA ZONA**

    // Configuración de ErrorWidget.builder (estaba causando el desajuste)
    ErrorWidget.builder = (FlutterErrorDetails details) => ErrorMessageWidget(
          title: 'Algo salió mal',
          message: 'No se pudo cargar la información...',
          buttonText: 'Cerrar la app',
          onPressed: () {
            exit(0);
          },
        );

    // Inicializa las preferencias
    await Preferences.init();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Inicializa Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 4. **CONFIGURACIÓN CLAVE DE CRASHLYTICS:**
    // Dirige todos los errores de Flutter (errores de UI, builds, etc.)
    // al reportero de Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // 5. Lógica de Cron
    var cron = Cron();

    // Primer Cron Job
    cron.schedule(Schedule.parse('*/1 * * * *'), () async {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          final isLogin = await PrefUtils.getIsLoggedIn();
          if (isLogin && navigatorKey.currentContext != null) {
            searchProductsNoSendOdoo(navigatorKey.currentContext!);
          }
        }
      } on SocketException catch (e, s) {
        // Registra errores de conexión (no fatales)
        FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      } catch (e, s) {
        // Registra cualquier otro error asíncrono en este cron
        FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      }
    });

    // Segundo Cron Job
    cron.schedule(Schedule.parse('*/1 * * * *'), () async {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          final isLogin = await PrefUtils.getIsLoggedIn();
          if (isLogin && navigatorKey.currentContext != null) {
            searchProductsPickNoSendOdoo(navigatorKey.currentContext!);
          }
        }
      } on SocketException catch (e, s) {
        // Registra errores de conexión (no fatales)
        FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      } catch (e, s) {
        // Registra cualquier otro error asíncrono en este cron
        FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      }
    });
    // WebSocketService().connect(); // Si lo necesitas

    // 6. Ejecuta la aplicación
    runApp(const MyApp());
  }, (error, stack) {
    // 7. **CALLBACK DE runZonedGuarded:** Captura errores asíncronos que
    // no fueron manejados por FlutterError.onError (ej. futures, isolates).
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ Reutilizamos la instancia única del ConnectionStatusCubit
        BlocProvider.value(value: connectionStatusCubit),

        // 👉 Resto de tus BLoC habituales
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => RecepcionBloc()),
        BlocProvider(create: (_) => TransferenciaBloc()),
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(create: (_) => WMSPickingBloc()),
        BlocProvider(create: (_) => BatchBloc()),
        BlocProvider(create: (_) => WmsPackingBloc()),
        BlocProvider(create: (_) => KeyboardBloc()),
        BlocProvider(create: (_) => TransferInfoBloc()),
        BlocProvider(create: (_) => InfoRapidaBloc()),
        BlocProvider(create: (_) => InventarioBloc()),
        BlocProvider(create: (_) => PickingPickBloc()),
        BlocProvider(create: (_) => RecepcionBatchBloc()),
        BlocProvider(create: (_) => PackingPedidoBloc()),
        BlocProvider(create: (_) => DevolucionesBloc()),
        BlocProvider(create: (_) => ConteoBloc()),
        BlocProvider(create: (_) => CreateTransferBloc()),
      ],
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.checkout,
        unknownRoute: GetPage(name: AppRoutes.home, page: () => HomePage()),
        supportedLocales: const [Locale('es', 'ES')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: AppRoutes.routes,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: AppBarTheme(elevation: 0, color: primaryColorApp),
          colorScheme: ColorScheme.light(
            primary: primaryColorApp,
            secondary: primaryColorApp,
          ),
        ),
        builder: (context, navigator) {
          apiRequestService.initialize(
            unencodePath: '/api',
            httpHandler: HttpResponseHandler(context),
          );
          return navigator!;
        },
      ),
    );
  }
}

///metodo el cual se encarga de verificar que productos estan con estado no enviado para enviarlos a odoo
void searchProductsNoSendOdoo(BuildContext context) async {
  DataBaseSqlite db = DataBaseSqlite();
  WmsPickingRepository repository = WmsPickingRepository();
  //traemos todos los productos
  final products = await db.getProducts();
  //filtramos la lista de produtos para dejar solo los productos que cumplan esta condicion is_send_odoo == 0
  final productsNoSendOdoo =
      products.where((element) => element.isSendOdoo == 0).toList();
  //recorremos la lista
  for (var product in productsNoSendOdoo) {
    DateTime fechaTransaccion = DateTime.now();
    String fechaFormateada = formatoFecha(fechaTransaccion);
    //TIEMPO DE INICIO DEL PRODUCTO
    final totalTime = await db.getFieldTableProducts(product.batchId ?? 0,
        product.idProduct ?? 0, product.idMove ?? 0, 'time_separate');

    final userId = await PrefUtils.getUserId();

    //enviamos el producto a odoo
    final response = await repository.sendPicking(
        idBatch: product.batchId ?? 0,
        timeTotal: 0,
        cantItemsSeparados: 0,
        listItem: [
          Item(
            idMove: product.idMove ?? 0,
            productId: product.idProduct ?? 0,
            lote: product.loteId.toString(),
            cantidad: (product.quantitySeparate ?? 0) > (product.quantity ?? 0)
                ? product.quantity ?? 0
                : product.quantitySeparate ?? 0,
            novedad: product.observation ?? 'Sin novedad',
            timeLine: totalTime == null ? 0.0 : double.parse(totalTime),
            muelle: product.idLocationDest ?? 0,
            idOperario: userId,
            fechaTransaccion: product.fechaTransaccion ?? fechaFormateada,
          ),
        ]);

    if (response.result?.code == 200) {
      //recorremos todos los resultados de la respuesta
      for (var resultProduct in response.result!.result!) {
        await db.setFieldTableBatchProducts(
          resultProduct.idBatch ?? 0,
          resultProduct.idProduct ?? 0,
          'is_send_odoo',
          1,
          resultProduct.idMove ?? 0,
        );
      }
    } else {
      //elementos que no se pudieron enviar a odoo
      await db.setFieldTableBatchProducts(
        product.batchId ?? 0,
        product.idProduct ?? 0,
        'is_send_odoo',
        0,
        product.idMove ?? 0,
      );
    }
  }
}

void searchProductsPickNoSendOdoo(BuildContext context) async {
  DataBaseSqlite db = DataBaseSqlite();
  TransferenciasRepository repository = TransferenciasRepository();
  //traemos todos los productos
  final products = await db.pickProductsRepository.getProducts();
  //filtramos la lista de produtos para dejar solo los productos que cumplan esta condicion is_send_odoo == 0
  final productsNoSendOdoo =
      products.where((element) => element.isSendOdoo == 0).toList();
  //recorremos la lista
  for (var product in productsNoSendOdoo) {
    final userId = await PrefUtils.getUserId();

    final response = await repository.sendProductTransferPick(
      TransferRequest(
        idTransferencia: product.batchId ?? 0,
        listItems: [
          ListItem(
            idMove: product.idMove ?? 0,
            idProducto: product.idProduct ?? 0,
            idLote: product.loteId ?? 0,
            idUbicacionDestino: product.muelleId ?? 0,
            cantidadEnviada: product.quantitySeparate ?? 0,
            idOperario: userId,
            timeLine: product.timeSeparate == null
                ? 30.0
                : product.timeSeparate.toDouble(),
            fechaTransaccion: product.fechaTransaccion ?? '',
            observacion: product.observation ?? 'Sin novedad',
            dividida: false,
          ),
        ],
      ),
      false,
    );

    if (response.result?.code == 200) {
      //recorremos todos los resultados de la respuesta
      for (var resultProduct in response.result!.result!) {
        db.pickProductsRepository.setFieldTablePickProducts(
          resultProduct.idTransferencia ?? 0,
          resultProduct.idProduct ?? 0,
          'is_send_odoo',
          1,
          resultProduct.idMove ?? 0,
        );
      }
    } else {
      //elementos que no se pudieron enviar a odoo
      db.pickProductsRepository.setFieldTablePickProducts(
        product.batchId ?? 0,
        product.idProduct ?? 0,
        'is_send_odoo',
        0,
        product.idMove ?? 0,
      );
    }
  }
}
