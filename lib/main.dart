// // ignore_for_file: depend_on_referenced_packages, avoid_print, use_build_context_synchronously

// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cron/cron.dart';
import 'package:flutter/services.dart';
import 'package:wms_app/routes/app_router.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/api/http_response_handler.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_bloc.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_picking_repository.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/item_picking_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/services/notification_service.dart';
// import 'package:wms_app/src/services/permission_service.dart';

import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wms_app/src/utils/formats.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

final internetChecker = CheckInternetConnection();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Card(
                color: white,
                elevation: 2,
                child: Text(
                    'Ocurrió un error inesperado, por favor reinicia la aplicación')),
          ),
        ),
      );

  WidgetsFlutterBinding.ensureInitialized();
  // await PermissionManager.requestAllPermissions();

  await LocalNotificationsService.reqyestPermissionsLocalNotifications();

  await LocalNotificationsService()
      .initializeNotifications(); // Llama a la función de inicialización
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const AppState());
  });
  // Inicializar la base de datos SQLite
  await Preferences.init();

  // cron
  var cron = Cron();
  cron.schedule(Schedule.parse('*/1 * * * *'), () async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final isLogin = await PrefUtils.getIsLoggedIn();
        if (isLogin) {
          searchProductsNoSendOdoo(navigatorKey.currentContext!);
        }
      }
    } on SocketException catch (_) {}
  });
}

class AppState extends StatelessWidget {
  const AppState({super.key});
  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserBloc(),
        ),
        BlocProvider(
          create: (_) => WMSPickingBloc(),
        ),
        BlocProvider(
          create: (_) => BatchBloc(),
        ),
        BlocProvider(
          create: (_) => WmsPackingBloc(),
        ),
        BlocProvider(
          create: (_) => KeyboardBloc(),
        )
      ],
      child: GetMaterialApp(
          navigatorKey: navigatorKey, // Usa el navigatorKey aquí
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.checkout, // Usa la constante de ruta

          supportedLocales: const [Locale('es', 'ES')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: AppRoutes.routes, // Usa el mapa de rutas
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.grey[300],
            appBarTheme: AppBarTheme(elevation: 0, color: primaryColorApp),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColorApp,
                  secondary: primaryColorApp,
                ),
          ),
          builder: (context, navigator) {
            final apiRequestService = ApiRequestService();
            apiRequestService.initialize(
              unencodePath: '/api',
              httpHandler: HttpResponseHandler(context),
            );
            return navigator!;
          }),
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
        context: context,
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
            timeLine: double.parse(totalTime),
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
          'true',
          resultProduct.idMove ?? 0,
        );
      }
    } else {
      //elementos que no se pudieron enviar a odoo
      await db.setFieldTableBatchProducts(
        product.batchId ?? 0,
        product.idProduct ?? 0,
        'is_send_odoo',
        'false',
        product.idMove ?? 0,
      );
    }
  }
}

void refreshData(BuildContext context) async {
  final String rol = await PrefUtils.getUserRol();
  if (rol == 'picking') {
    context.read<WMSPickingBloc>().add(LoadAllBatchsEvent(context, false));
  } else if (rol == 'admin') {
    context.read<WMSPickingBloc>().add(LoadAllBatchsEvent(context, false));
    context.read<WmsPackingBloc>().add(LoadAllPackingEvent(false, context));
  } else {
    context.read<WmsPackingBloc>().add(LoadAllPackingEvent(false, context));
  }
}
