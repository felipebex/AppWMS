// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/home/widgets/Dialog_ProductsNotSends.dart';
import 'package:wms_app/src/presentation/views/home/widgets/dialog_picking_widget.dart';
import 'package:wms_app/src/presentation/views/home/widgets/widget.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/modules/quick%20info/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/bloc/inventario_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    _onDataUser();

    // Añadimos el observer para escuchar el ciclo de vida de la app.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        // Aquí se ejecutan las acciones solo si la pantalla aún está montada
        showDialog(
          context: context,
          builder: (context) {
            return const DialogLoading(
              message: "Espere un momento...",
            );
          },
        );
        context.read<UserBloc>().add(LoadInfoDeviceEventUser());
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    }
  }

  void _onDataUser() async {
    context.read<HomeBloc>().add(HomeLoadData());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          print(" ❤️‍🔥 STATE: $state");

          if (state is HomeLoadErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Error al cargar la información del usuario"),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          return RefreshIndicator(
            onRefresh: () async {
              //mostramos dialogo
              showDialog(
                context: context,
                builder: (context) {
                  return const DialogLoading(
                    message: "Espere un momento...",
                  );
                },
              );

              //* generales
              context.read<WMSPickingBloc>().add(LoadAllNovedades(context)); //n
              context.read<UserBloc>().add(GetConfigurations(context));
              context.read<UserBloc>().add(GetUbicacionesEvent());
              context.read<UserBloc>().add(LoadInfoDeviceEventUser());

              //* ejecutamos los productos del almacen

              final products = await DataBaseSqlite().getProducts();

              final productsNoSendOdoo =
                  products.where((element) => element.isSendOdoo == 0).toList();

              if (productsNoSendOdoo.isEmpty) {
                if (!mounted) return;
                final String rol = await PrefUtils.getUserRol();

                //*picking
                if (rol == 'picking') {
                  if (!mounted) return;
                  await DataBaseSqlite().delePicking();
                  context.read<WMSPickingBloc>().add(LoadAllBatchsEvent(false));
                } else if (rol == 'packing') {
                  if (!mounted) return;
                  await DataBaseSqlite().delePacking();
                  context.read<WmsPackingBloc>().add(LoadAllPackingEvent(
                        false,
                      ));
                } else if (rol == "reception") {
                  if (!mounted) return;
                  await DataBaseSqlite().deleRecepcion();
                  context.read<RecepcionBloc>().add(FetchOrdenesCompra(false));
                } else if (rol == "transfer") {
                  if (!mounted) return;
                  await DataBaseSqlite().deleTrasnferencia();
                  context
                      .read<TransferenciaBloc>()
                      .add(FetchAllTransferencias(false));
                } else if (rol == "inventory") {
                  if (!mounted) return;
                  await DataBaseSqlite().deleInventario();
                  context.read<InventarioBloc>().add(GetProductsEvent());
                } else if (rol == "" || rol == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("El usuario no tiene cargado los permisos"),
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              } else {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const DialogProductsNotSends();
                    });
              }

              //esperamos 2 segundos para cerrar el dialogo
              await Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            },
            child: Scaffold(
              // floatingActionButton: FloatingActionButton(
              //   backgroundColor: primaryColorApp,
              //   onPressed: () {
              //     context.read<InventarioBloc>().add(GetProductsForDB());
              //   },
              //   child: const Icon(Icons.settings),
              // ),
              backgroundColor: white,
              body: Container(
                color: white,
                width: size.width,
                height: size.height,
                // color: primaryColorApp, // Color de fondo blanco
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0, // Posicionar en la parte inferior
                      child: ClipPath(
                        clipper: HalfCircleClipper(),
                        child: Container(
                          height: size.height * 0.3, // Altura del medio círculo
                          // color: Colors.grey[350], // Color azul
                          color: primaryColorApp, // Color azul
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width,
                      height: size.height,
                      child: SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Asegura que funcione el pull-to-refresh
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const WarningWidgetCubit(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: white,
                                elevation: 2,
                                child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 40),
                                    width: size.width,
                                    height: 160,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text("Bienvenido a, ",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            primaryColorApp)),
                                                // Text('WMS',
                                                Text('OnPoint',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            primaryColorApp)),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                context.read<UserBloc>().add(
                                                    GetConfigurations(context));

                                                context.read<UserBloc>().add(
                                                    LoadInfoDeviceEventUser());
                                                context
                                                    .read<UserBloc>()
                                                    .add(GetUbicacionesEvent());

                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const DialogLoading(
                                                        message:
                                                            'Cargando información del usuario...',
                                                      );
                                                    });

                                                // Esperar 3 segundos antes de continuar
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 300), () {
                                                  Navigator.pop(context);
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, 'user');
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(Icons.person,
                                                      color: primaryColorApp,
                                                      size: 20),
                                                  Text("Hola, ",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: black)),
                                                  SizedBox(
                                                    width: size.width * 0.5,
                                                    child: Text(
                                                      homeBloc.userName,
                                                      style: TextStyle(
                                                        // color: Colors.amber[200],
                                                        color: primaryColorApp,
                                                        fontSize: 18,
                                                        // fontWeight:
                                                        //     FontWeight.bold
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(Icons.email,
                                                    color: primaryColorApp,
                                                    size: 18),
                                                const SizedBox(width: 5),
                                                SizedBox(
                                                  width: size.width * 0.6,
                                                  child: Text(
                                                    homeBloc.userEmail,
                                                    style: const TextStyle(
                                                        color: black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.storage,
                                                    color: primaryColorApp,
                                                    size: 18),
                                                const SizedBox(width: 5),
                                                SizedBox(
                                                  width: size.width * 0.6,
                                                  child: Text(
                                                    Preferences.nameDatabase
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.security,
                                                    color: primaryColorApp,
                                                    size: 18),
                                                const SizedBox(width: 5),
                                                SizedBox(
                                                  width: size.width * 0.6,
                                                  child: Text(
                                                    homeBloc.userRol,
                                                    style: const TextStyle(
                                                        color: black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        //ICONO DE CERRAR SESION
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const CloseSession();
                                                });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 20),
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: white,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Icon(Icons.logout,
                                                color: primaryColorApp),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ),

                            //todo informativo para los modulos
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Text("Mis módulos",
                                    style: TextStyle(
                                        color: primaryColorApp,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                width: size.width,
                                height: size.height * 0.4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final String rol =
                                                await PrefUtils.getUserRol();

                                            if (rol == 'picking' ||
                                                rol == 'admin') {
                                              context.read<BatchBloc>().add(
                                                  LoadAllNovedadesEvent()); //
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return DialogPicking(
                                                    contextHome: context,
                                                  );
                                                },
                                              );
                                              // context.read<BatchBloc>().add(
                                              //     LoadAllNovedadesEvent()); //

                                              // showDialog(
                                              //     context: context,
                                              //     builder: (context) {
                                              //       return const DialogLoading(
                                              //           message:
                                              //               'Cargando interfaz...');
                                              //     });

                                              // await Future.delayed(const Duration(
                                              //     seconds:
                                              //         1)); // Ajusta el tiempo si es necesario
                                              // Navigator.pop(context);
                                              // Navigator.pushReplacementNamed(
                                              //     context, 'wms-picking',
                                              //     arguments: 0);
                                            } else if (rol == '' ||
                                                rol == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Cargue la configuración de su usuario"),
                                                  duration:
                                                      Duration(seconds: 4),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Su usuario no tiene permisos para acceder a este módulo"),
                                                  duration:
                                                      Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          },
                                          child: BlocBuilder<WMSPickingBloc,
                                              PickingState>(
                                            builder: (context, state) {
                                              return ImteModule(
                                                count: (context
                                                    .read<WMSPickingBloc>()
                                                    .listOfBatchs
                                                    .where((element) {
                                                  return element.isSeparate ==
                                                          0 ||
                                                      element.isSeparate ==
                                                          null;
                                                }).length),
                                                urlImg: "picking.png",
                                                title: 'Picking',
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        GestureDetector(
                                          onTap: () async {
                                            context
                                                .read<UserBloc>()
                                                .add(LoadInfoDeviceEventUser());
                                            final String rol =
                                                await PrefUtils.getUserRol();

                                            if (rol == 'packing' ||
                                                rol == 'admin') {
                                              context.read<WmsPackingBloc>().add(
                                                  LoadAllNovedadesPackingEvent());

                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const DialogLoading(
                                                        message:
                                                            'Cargando packing...');
                                                  });

                                              // Esperar 3 segundos antes de continuar
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500), () {
                                                Navigator.pop(context);
                                                Navigator.pushReplacementNamed(
                                                    context, 'wms-packing');
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Su usuario no tiene permisos para acceder a este módulo"),
                                                  duration:
                                                      Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          },
                                          child: BlocBuilder<WmsPackingBloc,
                                              WmsPackingState>(
                                            builder: (context, state) {
                                              return ImteModule(
                                                count: context
                                                    .read<WmsPackingBloc>()
                                                    .listOfBatchs
                                                    .where((element) {
                                                  return element.isPacking ==
                                                          0 ||
                                                      element.isPacking == null;
                                                }).length,
                                                urlImg: "packing.png",
                                                title: 'Packing',
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        GestureDetector(
                                          onTap: () async {
                                            //cargamos inforacion del dispositivo
                                            context
                                                .read<UserBloc>()
                                                .add(LoadInfoDeviceEventUser());
                                            //cargamos las ubicaciones
                                            context
                                                .read<InfoRapidaBloc>()
                                                .add(GetListLocationsEvent());
                                            //obtenemos los productos
                                            context
                                                .read<InfoRapidaBloc>()
                                                .add(GetProductsList());

                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const DialogLoading(
                                                      message:
                                                          'Cargando interfaz...');
                                                });

                                            await Future.delayed(const Duration(
                                                seconds:
                                                    1)); // Ajusta el tiempo si es necesario

                                            Navigator.pop(context);
                                            Navigator.pushReplacementNamed(
                                              context,
                                              'info-rapida',
                                            );
                                          },
                                          child: const ImteModule(
                                            urlImg: "info.png",
                                            title: 'Info Rapida',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            if (homeBloc.userRol ==
                                                    'reception' ||
                                                homeBloc.userRol == 'admin') {
                                              //pedir ubicaciones
                                              // context
                                              //     .read<RecepcionBloc>()
                                              //     .add(GetLocationsDestEvent());
                                              // //pedir info del usuario

                                              // context.read<UserBloc>().add(
                                              //     LoadInfoDeviceEventUser());

                                              // //pedir las novedades
                                              // context.read<RecepcionBloc>().add(
                                              //     LoadAllNovedadesOrderEvent());

                                              // showDialog(
                                              //     context: context,
                                              //     builder: (context) {
                                              //       return const DialogLoading(
                                              //           message:
                                              //               'Cargando recepciones...');
                                              //     });

                                              // await Future.delayed(const Duration(
                                              //     seconds:
                                              //         1)); // Ajusta el tiempo si es necesario

                                              // Navigator.pop(context);
                                              // Navigator.pushReplacementNamed(
                                              //   context,
                                              //   'list-ordenes-compra',
                                              // );

                                              Navigator.pushReplacementNamed(
                                                context,
                                                'list-recepction-batch',
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Su usuario no tiene permisos para acceder a este módulo"),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                          child: BlocBuilder<RecepcionBloc,
                                              RecepcionState>(
                                            builder: (context, state) {
                                              return ImteModule(
                                                count: context
                                                    .read<RecepcionBloc>()
                                                    .listFiltersOrdenesCompra
                                                    .where((element) =>
                                                        element.isFinish == 0 ||
                                                        element.isFinish ==
                                                            null)
                                                    .length,
                                                urlImg: "recepcion.png",
                                                title: 'Recepción',
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        GestureDetector(
                                          onTap: () async {
                                            if (homeBloc.userRol ==
                                                    'transfer' ||
                                                homeBloc.userRol == 'admin') {
                                              if (context
                                                  .read<UserBloc>()
                                                  .ubicaciones
                                                  .isEmpty) {
                                                context
                                                    .read<UserBloc>()
                                                    .add(GetUbicacionesEvent());
                                              }

                                              context.read<TransferenciaBloc>().add(
                                                  LoadAllNovedadesTransferEvent());
                                              context
                                                  .read<TransferenciaBloc>()
                                                  .add(LoadLocations());

                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const DialogLoading(
                                                        message:
                                                            'Cargando interfaz...');
                                                  });

                                              await Future.delayed(const Duration(
                                                  seconds:
                                                      1)); // Ajusta el tiempo si es necesario

                                              Navigator.pop(context);

                                              Navigator.pushReplacementNamed(
                                                context,
                                                'transferencias',
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Su usuario no tiene permisos para acceder a este módulo"),
                                                  duration:
                                                      Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          },
                                          child: BlocBuilder<TransferenciaBloc,
                                              TransferenciaState>(
                                            builder: (context, state) {
                                              return ImteModule(
                                                count: context
                                                    .read<TransferenciaBloc>()
                                                    .transferenciasDbFilters
                                                    .where((element) =>
                                                        element.isFinish == 0 ||
                                                        element.isFinish ==
                                                            null)
                                                    .toList()
                                                    .length,
                                                urlImg: "transferencia.png",
                                                title: 'Transferencia',
                                              );
                                            },
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            if (homeBloc.userRol ==
                                                    'inventory' ||
                                                homeBloc.userRol == 'admin') {
                                              //obtenemos las ubicaciones
                                              context
                                                  .read<InventarioBloc>()
                                                  .add(GetLocationsEvent());
                                              //obtenemos los productos
                                              context
                                                  .read<InventarioBloc>()
                                                  .add(GetProductsForDB());
                                              //cargamos la configuracion
                                              context.read<InventarioBloc>().add(
                                                  LoadConfigurationsUserInventory());

                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const DialogLoading(
                                                        message:
                                                            'Cargando inventario rapido...');
                                                  });

                                              await Future.delayed(const Duration(
                                                  seconds:
                                                      1)); // Ajusta el tiempo si es necesario

                                              Navigator.pop(context);
                                              Navigator.pushReplacementNamed(
                                                context,
                                                'inventario',
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Su usuario no tiene permisos para acceder a este módulo"),
                                                  duration:
                                                      Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          },
                                          child: ImteModule(
                                            urlImg: "inventario.png",
                                            title: 'Inventario',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text("Onpoint",
                                        style: TextStyle(
                                          color: grey,
                                          fontSize: 12,
                                        )),
                                    Text("© 2025 - 360 Software",
                                        style: TextStyle(
                                          color: grey,
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
