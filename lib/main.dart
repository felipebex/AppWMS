// ignore_for_file: depend_on_referenced_packages

import 'package:wms_app/src/presentation/blocs/network/network_bloc.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/bloc/entreprise_bloc.dart';
import 'package:wms_app/src/presentation/views/global/login/bloc/login_bloc.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/cronometro/cronometro_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_detail.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_detail2.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_picking_screen.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppState());

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //BLOC PROVIDERS
        BlocProvider(
          create: (_) => NetworkBloc()..add(NetworkObserve()),
        ),
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
          create: (_) => HomeBloc(),
        ),
        BlocProvider(
          create: (_) => CronometroBloc(),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        // initialRoute: 'batch-products2',
        initialRoute: 'checkout',
        supportedLocales: const [Locale('es', 'ES')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          // 'cronometro' : (_) => const CronometroPage(),
          //* Global
          'enterprice': (_) => const SelectEnterpricePage(),
          'auth': (_) => const LoginPage(),
          'checkout': (_) => const CheckAuthPage(),

          //* wms Picking
          'wms-picking': (_) => const WMSPickingPage(),
          'batch-picking': (_) => const BatchPickingScreen(),

          //*others
          'confirmation': (_) => const ConfirmationPage(),
          'yms': (_) => const YMSPage(),
          'counter': (_) => const CounterPage(),
          'home': (_) => const HomePage(),
          'ventor': (_) => const VentorHome(),
          'batch-products': (_) => const BatchDetailScreen(),
          'batch-products2': (_) => const BatchDetail2Screen(),
        },
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: const AppBarTheme(elevation: 0, color: primaryColorApp),
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: primaryColorApp,
                secondary: primaryColorApp,
              ),
        ),
      ),
    );
  }
}
