// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:io';

import 'package:cron/cron.dart';
import 'package:flutter/services.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/api/http_response_handler.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/bloc/entreprise_bloc.dart';
import 'package:wms_app/src/presentation/views/global/login/bloc/login_bloc.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/packing_list.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/data/wms_piicking_rerpository.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/item_picking_request.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_detail.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_screen.dart';

import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/presentation/views/wms_packing/presentation/screens/packing_detail.dart';

final internetChecker = CheckInternetConnection();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const AppState());
  });
  // Inicializar la base de datos SQLite
  await Preferences.init();

  //cron
  var cron = Cron();
  cron.schedule(Schedule.parse('*/1 * * * *'), () async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        searchProductsNoSendOdoo();
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
        //bloc de network
        BlocProvider(
          create: (_) => LoginBloc(),
        ),
        BlocProvider(
          create: (_) => EntrepriseBloc(),
        ),
        BlocProvider(
          create: (_) => WMSPickingBloc(),
        ),
        BlocProvider(
          create: (_) => BatchBloc(),
        ),
        BlocProvider(
          create: (context) => HomeBloc(
            context,
          ),
        ),
        BlocProvider(
          create: (_) => WmsPackingBloc(),
        ),
      ],
      child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: 'checkout',
          supportedLocales: const [Locale('es', 'ES')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            //* Global
            'enterprice': (_) => const SelectEnterpricePage(),
            'auth': (_) => const LoginPage(),
            'checkout': (_) => const CheckAuthPage(),

            //* wms Picking
            'wms-picking': (_) => const WMSPickingPage(),
            'batch': (_) => const BatchScreen(),
            'batch-detail': (_) => const BatchDetailScreen(),

            //*wms Packing
            'wms-packing': (_) => const WmsPackingScreen(),

            'packing-list': (context) => PakingListScreen(
                batchModel: ModalRoute.of(context)!.settings.arguments
                    as BatchPackingModel?),

            'Packing': (_) => PackingScreen(),

            'packing-detail': (context) => PackingDetailScreen(
                packingModel: ModalRoute.of(context)!.settings.arguments
                    as PedidoPacking?),

            //*others
            'confirmation': (_) => const ConfirmationPage(),
            'yms': (_) => const YMSPage(),
            'counter': (_) => const CounterPage(),
            'home': (_) => const HomePage(),
            'ventor': (_) => const VentorHome(),
          },
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.grey[300],
            appBarTheme:
                const AppBarTheme(elevation: 0, color: primaryColorApp),
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
void searchProductsNoSendOdoo() async {
  DataBaseSqlite db = DataBaseSqlite();
  WmsPickingRepository repository = WmsPickingRepository();
  //traemos todos los productos
  final products = await db.getProducts();
  //filtramos la lista de produtos para dejar solo los productos que cumplan esta condicion is_send_odoo == 0
  final productsNoSendOdoo =
      products.where((element) => element.isSendOdoo == 0).toList();
  //recorremos la lista
  for (var product in productsNoSendOdoo) {
    //enviamos el producto a odoo
    final response = await repository.sendPicking(
        idBatch: product.batchId ?? 0,
        timeTotal: 0,
        cantItemsSeparados: 0,
        listItem: [
          Item(
            idMove: product.idMove ?? 0,
            productId: product.idProduct ?? 0,
            lote: product.lotId ?? '',
            cantidad: product.quantitySeparate ?? 0,
            novedad: product.observation ?? '',
            timeLine: 0,
          ),
        ]);
    print("response searchProductsNoSendOdoo: ${response.data?.code} ");
    if (response.data?.code == 200) {
      //recorremos todos los resultados de la respuesta
      for (var resultProduct in response.data!.result) {
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
