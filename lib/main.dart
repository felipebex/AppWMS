// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_print

import 'dart:io';
import 'dart:async'; // <--- AÑADIR ESTA IMPORTACIÓN
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:wms_app/firebase_options.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/routes/app_router.dart';
import 'package:wms_app/src/api/api_request_service.dart';
import 'package:wms_app/src/api/http_response_handler.dart';
import 'package:wms_app/src/core/utils/widgets/error_widget.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/bloc/devoluciones_bloc.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/modules/quick%20info/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/modules/transfer/bloc/transfer_info_bloc.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/bloc/inventario_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/batchs/bloc/recepcion_batch_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/create-transfer/bloc/crate_transfer_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-consolidade/bloc/packing_consolidade_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/packing_pedido_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ApiRequestService apiRequestService = ApiRequestService();

// ✅ Instancias únicas
final internetChecker = CheckInternetConnection();
final connectionStatusCubit =
    ConnectionStatusCubit(internetChecker: internetChecker);
void main() async {
  
  // 1. **NO SE LLAMA ensureInitialized AQUÍ**

  // 2. INICIAR LA ZONA DE CAPTURA DE ERRORES (Crashlytics)
  await runZonedGuarded<Future<void>>(() async {
    
    // ✅ CORRECCIÓN CLAVE: Inicializar los bindings DENTRO de la Zona
    WidgetsFlutterBinding.ensureInitialized(); 

    // TAREAS PESADAS Y CRÍTICAS DENTRO DE LA ZONA SEGURA:
    await Preferences.init();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Inicializa Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configuración de Manejadores
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Configuración de ErrorWidget.builder
    ErrorWidget.builder = (FlutterErrorDetails details) => ErrorMessageWidget(
          title: 'Algo salió mal',
          message: 'No se pudo cargar la información...',
          buttonText: 'Cerrar la app',
          onPressed: () {
            exit(0);
          },
        );
        
    // 4. Ejecuta la aplicación
    runApp(const MyApp());
    
  }, (error, stack) {
    // 5. CALLBACK DE runZonedGuarded: Captura errores asíncronos restantes
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
        BlocProvider(create: (_) => PackingConsolidateBloc()),
      ],
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.checkout,
        routes: AppRoutes.routes,
        supportedLocales: const [Locale('es', 'ES')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
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
