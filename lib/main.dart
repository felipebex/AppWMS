// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/services.dart';
import 'package:wms_app/src/api/dio_factory.dart';
import 'package:wms_app/src/presentation/blocs/network/network_bloc.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/bloc/entreprise_bloc.dart';
import 'package:wms_app/src/presentation/views/global/login/bloc/login_bloc.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/pages.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/screens/packing_list.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/cronometro/cronometro_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_detail.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/batch_screen.dart';

import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/presentation/views/wms_packing/presentation/screens/packing_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    DioFactory.computeDeviceInfo();
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
          create: (context) => HomeBloc(
            context,
          ),
        ),
        BlocProvider(
          create: (_) => CronometroBloc(),
        ),
        BlocProvider(
          create: (_) => WmsPackingBloc(),
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
          // 'batch-picking': (_) => const BatchPickingScreen(),

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
              batchModel:
                  ModalRoute.of(context)!.settings.arguments as BatchsModel?),

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
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'PDA Scanner Example',
//       home: PDAScannerScreen(),
//     );
//   }
// }

// class PDAScannerScreen extends StatefulWidget {
//   const PDAScannerScreen({super.key});

//   @override
//   _PDAScannerScreenState createState() => _PDAScannerScreenState();
// }

// class _PDAScannerScreenState extends State<PDAScannerScreen> {
//   String scannedValue1 = '';
//   String scannedValue2 = '';

//   FocusNode focusNode1 = FocusNode();
//   FocusNode focusNode2 = FocusNode();

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Mover la solicitud de foco aquí
//     FocusScope.of(context).requestFocus(focusNode1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDA Scanner Example'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Focus(
//             focusNode: focusNode1,
//             onKey: (FocusNode node, RawKeyEvent event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.enter) {
//                   if (scannedValue1.isNotEmpty) {
//                     print('Escaneado 1: $scannedValue1');
//                     FocusScope.of(context).requestFocus(focusNode2);
//                   }
//                   return KeyEventResult.handled;
//                 } else {
//                   setState(() {
//                     scannedValue1 += event.data.keyLabel;
//                   });
//                   return KeyEventResult.handled;
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
              
//                   Text(
//                     'Escaneado 1: $scannedValue1',
//                     style: const TextStyle(fontSize: 24),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const Divider(),
//           Focus(
//             focusNode: focusNode2,
//             onKey: (FocusNode node, RawKeyEvent event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.enter) {
//                   print('Escaneado 2: $scannedValue2');
//                   return KeyEventResult.handled;
//                 } else {
//                   setState(() {
//                     scannedValue2 += event.data.keyLabel;
//                   });
//                   return KeyEventResult.handled;
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Escaneado 2: $scannedValue2',
//                     style: const TextStyle(fontSize: 24),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
