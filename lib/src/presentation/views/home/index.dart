// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/home/widgets/Dialog_ProductsNotSends.dart';
import 'package:wms_app/src/presentation/views/home/widgets/widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
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
  void initState() {
    super.initState();

    // Añadimos el observer para escuchar el ciclo de vida de la app.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        // Aquí se ejecutan las acciones solo si la pantalla aún está montada
        context.read<HomeBloc>().add(AppVersionEvent(context));
      }
    }
  }

  @override
  void dispose() {
    // Eliminamos el observer para evitar fugas de memoria.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

          if (state is HomeLoadedState) {
            context.read<HomeBloc>().add(AppVersionEvent(context));
          }

          if (state is AppVersionUpdateState) {
            showDialog(
                context: context,
                builder: (context) {
                  return UpdateAppDialog();
                });
          }
        },
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          return RefreshIndicator(
            onRefresh: () async {
              //verficiar si tenemos algun producto sin enviar
              DataBaseSqlite db = DataBaseSqlite();
              //traemos todos los productos
              context.read<UserBloc>().add(LoadInfoDeviceEventUser());
              final products = await db.getProducts();
              final productsNoSendOdoo =
                  products.where((element) => element.isSendOdoo == 0).toList();
              if (productsNoSendOdoo.isEmpty) {
                await DataBaseSqlite().deleteBD();
                //peticion para la configuracion
                if (!mounted) return;
                final String rol = await PrefUtils.getUserRol();
                //peticion segun el rol del usuario
                if (rol == 'picking') {
                  if (!mounted) return;
                  context
                      .read<WMSPickingBloc>()
                      .add(LoadAllBatchsEvent(context, true));
                } else if (rol == 'admin') {
                  if (!mounted) return;
                  context
                      .read<WMSPickingBloc>()
                      .add(LoadAllBatchsEvent(context, true));
                  //esperamos 1 segundo y realizamos la otra peticion
                  await Future.delayed(const Duration(seconds: 1));
                  context
                      .read<WmsPackingBloc>()
                      .add(LoadAllPackingEvent(false, context));
                } else if (rol == 'packing') {
                  if (!mounted) return;
                  context
                      .read<WmsPackingBloc>()
                      .add(LoadAllPackingEvent(true, context));
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
            },
            child: Scaffold(
              body: Container(
                width: size.width,
                height: size.height,
                color: primaryColorApp, // Color de fondo blanco
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
                          color: white, // Color azul
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
                            Container(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 40),
                                width: size.width,
                                height: 130,
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Bienvenido a, ",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: white)),
                                            // Text('WMS',
                                            Text('OnPoint',
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: white)),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            context.read<UserBloc>().add(
                                                GetConfigurations(context));
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
                                              Navigator.pushReplacementNamed(
                                                  context, 'user');
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Container(
                                                  color: white,
                                                  height: 25,
                                                  width: 25,
                                                  child: Icon(Icons.person,
                                                      color: primaryColorApp,
                                                      size: 20),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text("Hola, ",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: white)),
                                              SizedBox(
                                                width: size.width * 0.5,
                                                child: Text(
                                                  homeBloc.userName,
                                                  style: TextStyle(
                                                      color: Colors.amber[200],
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                color: Colors.amber[200],
                                                size: 18),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              width: size.width * 0.6,
                                              child: Text(
                                                homeBloc.userEmail,
                                                style: const TextStyle(
                                                    color: white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.storage,
                                                color: Colors.amber[200],
                                                size: 18),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              width: size.width * 0.6,
                                              child: Text(
                                                Preferences.nameDatabase
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                        margin:
                                            const EdgeInsets.only(right: 20),
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

                            //todo: informativo para picking
                            Visibility(
                              visible: homeBloc.userRol == 'picking' ||
                                  homeBloc.userRol == 'admin',
                              child: Center(
                                child:
                                    BlocBuilder<WMSPickingBloc, PickingState>(
                                  builder: (context, state) {
                                    return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        width: size.width,
                                        height: 50,
                                        child: GestureDetector(
                                          onTap: () async {
                                            context
                                                .read<UserBloc>()
                                                .add(LoadInfoDeviceEventUser());
                                            final String rol =
                                                await PrefUtils.getUserRol();

                                            if (rol == 'picking' ||
                                                rol == 'admin') {
                                              context
                                                  .read<WMSPickingBloc>()
                                                  .add(
                                                      FilterBatchesBStatusEvent(
                                                    '',
                                                  ));

                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const DialogLoading(
                                                      message:
                                                          'Cargando batchs...',
                                                    );
                                                  });

                                              // Esperar 3 segundos antes de continuar
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 300), () {
                                                Navigator.pop(context);
                                                Navigator.pushReplacementNamed(
                                                    context, 'wms-picking',
                                                    arguments: 0);
                                              });
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
                                          child: ItemList(
                                            size: size,
                                            color: primaryColorApp,
                                            title: 'BATCH PICKING En Proceso',
                                            value: (context
                                                        .read<WMSPickingBloc>()
                                                        .listOfBatchs
                                                        .length -
                                                    context
                                                        .read<WMSPickingBloc>()
                                                        .batchsDone
                                                        .where((element) {
                                                      return element
                                                              .isSeparate ==
                                                          1;
                                                    }).length)
                                                .toString(),
                                          ),
                                        ));
                                  },
                                ),
                              ),
                            ),
                            //todo: informativo para packing
                            Visibility(
                              visible: homeBloc.userRol == 'packing' ||
                                  homeBloc.userRol == 'admin',
                              child: Center(
                                child:
                                    BlocBuilder<WMSPickingBloc, PickingState>(
                                  builder: (context, state) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      width: size.width,
                                      height: 50,
                                      child: GestureDetector(
                                        onTap: () async {
                                          context
                                              .read<UserBloc>()
                                              .add(LoadInfoDeviceEventUser());
                                          final String rol =
                                              await PrefUtils.getUserRol();

                                          if (rol == 'packing' ||
                                              rol == 'admin') {
                                            context.read<WmsPackingBloc>().add(
                                                LoadBatchPackingFromDBEvent());

                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const DialogLoading(
                                                      message:
                                                          'Cargando packing...');
                                                });

                                            // Esperar 3 segundos antes de continuar
                                            Future.delayed(
                                                const Duration(seconds: 1), () {
                                              Navigator.pop(context);
                                              Navigator.pushReplacementNamed(
                                                  context, 'wms-packing');
                                            });
                                          } else if (rol == '' || rol == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Cargue la configuración de su usuario"),
                                                duration: Duration(seconds: 4),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Su usuario no tiene permisos para acceder a este módulo"),
                                                duration: Duration(seconds: 4),
                                              ),
                                            );
                                          }
                                        },
                                        child: ItemList(
                                          size: size,
                                          color: primaryColorApp,
                                          title: 'BATCH PACKING En Proceso',
                                          value: (context
                                                      .read<WmsPackingBloc>()
                                                      .listOfBatchs
                                                      .length -
                                                  context
                                                      .read<WmsPackingBloc>()
                                                      .listOfBatchsDoneDB
                                                      .where((element) {
                                                    return DateTime.parse(element
                                                                    .timeSeparateEnd ??
                                                                "")
                                                            .toString()
                                                            .substring(0, 10) ==
                                                        DateTime.now()
                                                            .toString()
                                                            .substring(0, 10);
                                                  }).length)
                                              .toString(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            //todo informativo para packing
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text("Mis módulos",
                                  style: TextStyle(
                                      color: white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                width: size.width,
                                height: size.height * 0.55,
                                child: Column(
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
                                              context
                                                  .read<WMSPickingBloc>()
                                                  .add(
                                                      FilterBatchesBStatusEvent(
                                                    '',
                                                  ));
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const DialogLoading(
                                                        message:
                                                            'Cargando batchs...');
                                                  });

                                              await Future.delayed(const Duration(
                                                  seconds:
                                                      1)); // Ajusta el tiempo si es necesario

                                              Navigator.pop(context);
                                              Navigator.pushReplacementNamed(
                                                  context, 'wms-picking',
                                                  arguments: 0);
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
                                          child: const ImteModule(
                                            urlImg: "picking.png",
                                            title: 'WMS Picking',
                                          ),
                                        ),
                                        const SizedBox(width: 5),
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
                                                  LoadBatchPackingFromDBEvent());

                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const DialogLoading(
                                                        message:
                                                            'Cargando packing...');
                                                  });

                                              // Esperar 3 segundos antes de continuar
                                              Future.delayed(
                                                  const Duration(seconds: 1),
                                                  () {
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
                                          child: const ImteModule(
                                            urlImg: "packing.png",
                                            title: 'WMS Packing',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ImteModule(
                                          urlImg: "inventario.png",
                                          title: 'WMS Conteo',
                                        ),
                                        SizedBox(width: 5),
                                        ImteModule(
                                          urlImg: "yms.png",
                                          title: 'YMS',
                                        ),
                                      ],
                                    ),
                                  ],
                                ))
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
