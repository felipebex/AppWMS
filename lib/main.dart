// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/services.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/api/http_response_handler.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/bloc/entreprise_bloc.dart';
import 'package:wms_app/src/presentation/views/global/login/bloc/login_bloc.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/packing.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
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

          // 'packing-list': (context) => PakingListScreen(
          //     batchModel:
          //         ModalRoute.of(context)!.settings.arguments as BatchsModel?),

          'Packing': (_) => const PackingScreen(),

          'packing-detail': (context) => PackingDetailScreen(
              packingModel:
                  ModalRoute.of(context)!.settings.arguments as Packing?),

          //*others
          'confirmation': (_) => const ConfirmationPage(),
          'yms': (_) => const YMSPage(),
          'counter': (_) => const CounterPage(),
          'home': (_) => const HomePage(),
          'ventor': (_) => const VentorHome(),
        },
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: const AppBarTheme(elevation: 0, color: primaryColorApp),
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
        }
      ),
    );
  }
}
