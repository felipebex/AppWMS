// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';

import 'package:wms_app/environment/environment.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String userEmail = '';
  String userRol = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userName = await PrefUtils.getUserName();
    userEmail = await PrefUtils.getUserEmail();
    userRol = await PrefUtils.getUserRol();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              //peticion para la configuracion
              context.read<UserBloc>().add(GetConfigurations(context));
              final String rol = await PrefUtils.getUserRol();
              //peticion segun el rol del usuario
              if (rol == 'picking') {
                context
                    .read<WMSPickingBloc>()
                    .add(LoadAllBatchsEvent(context, true));
              } else {
                context
                    .read<WmsPackingBloc>()
                    .add(LoadAllPackingEvent(true, context));
              }
            },
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () async{
                  await DataBaseSqlite().deleteAll();
                },
                child: const Icon(Icons.refresh),
              ),
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
                                height: 120,
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
                                            Text(Environment.flavor.appName,
                                                style: const TextStyle(
                                                    fontSize: 18, color: white))
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // context
                                            //     .read<UserBloc>()
                                            //     .add(GetConfigurations());
                                            Navigator.pushNamed(
                                                context, 'user');
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
                                                  userName,
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
                                                userEmail,
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
                                              return BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 5, sigmaY: 5),
                                                child: AlertDialog(
                                                  actionsAlignment:
                                                      MainAxisAlignment.center,
                                                  backgroundColor: white,
                                                  title: Center(
                                                      child: Text(
                                                          'Cerrar sesión',
                                                          style: TextStyle(
                                                              color:
                                                                  primaryColorApp))),
                                                  content: const Text(
                                                      '¿Estás seguro de que deseas cerrar sesión?'),
                                                  actions: [
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        minimumSize:
                                                            const Size(100, 40),
                                                        backgroundColor: grey,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        'Cancelar',
                                                        style: TextStyle(
                                                          color: white,
                                                          fontSize: 14,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        minimumSize:
                                                            const Size(100, 40),
                                                        backgroundColor:
                                                            primaryColorApp,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        PrefUtils.clearPrefs();
                                                        //limpiamos toda la base de datos

                                                        Preferences
                                                            .removeUrlWebsite();
                                                        DataBaseSqlite()
                                                            .deleteAll();

                                                        PrefUtils.setIsLoggedIn(
                                                            false);
                                                        Navigator
                                                            .pushNamedAndRemoveUntil(
                                                                context,
                                                                'enterprice',
                                                                (route) =>
                                                                    false);
                                                      },
                                                      child: const Text(
                                                        'Aceptar',
                                                        style: TextStyle(
                                                          color: white,
                                                          fontSize: 14,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
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
                            Center(
                              child: BlocBuilder<WMSPickingBloc, PickingState>(
                                builder: (context, state) {
                                  return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      width: size.width,
                                      height: 50,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              final String rol =
                                                  await PrefUtils.getUserRol();

                                              if (rol == 'picking') {
                                                context
                                                    .read<WMSPickingBloc>()
                                                    .add(
                                                        LoadBatchsFromDBEvent());

                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const DialogLoading();
                                                    });

                                                // Esperar 3 segundos antes de continuar
                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  Navigator.pop(context);
                                                  Navigator.pushNamed(
                                                      context, 'wms-picking',
                                                      arguments: 1);
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
                                            child: _ItemList(
                                              size: size,
                                              color: green,
                                              title: 'BATCH Hechos',
                                              value: context
                                                  .read<WMSPickingBloc>()
                                                  .batchsDone
                                                  .where((element) =>
                                                      element.scheduleddate ==
                                                      DateTime.now()
                                                          .toString()
                                                          .substring(0, 10))
                                                  .length
                                                  .toString(),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              final String rol =
                                                  await PrefUtils.getUserRol();

                                              if (rol == 'picking') {
                                                context
                                                    .read<WMSPickingBloc>()
                                                    .add(
                                                        LoadBatchsFromDBEvent());

                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const DialogLoading();
                                                    });

                                                // Esperar 3 segundos antes de continuar
                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  Navigator.pop(context);
                                                  Navigator.pushNamed(
                                                      context, 'wms-picking',
                                                      arguments: 0);
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
                                            child: _ItemList(
                                              size: size,
                                              color: primaryColorApp,
                                              title: 'BATCH En Proceso',
                                              value: (context
                                                          .read<
                                                              WMSPickingBloc>()
                                                          .listOfBatchs
                                                          .length -
                                                      context
                                                          .read<
                                                              WMSPickingBloc>()
                                                          .batchsDone
                                                          .length)
                                                  .toString(),
                                            ),
                                          ),
                                        ],
                                      ));
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
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
                                            //verficamos que rol tiene el usuario
                                            final String rol =
                                                await PrefUtils.getUserRol();

                                            if (rol == 'picking') {
                                              context
                                                  .read<WMSPickingBloc>()
                                                  .add(LoadBatchsFromDBEvent());

                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const DialogLoading();
                                                  });

                                              // Esperar 3 segundos antes de continuar
                                              Future.delayed(
                                                  const Duration(seconds: 1),
                                                  () {
                                                Navigator.pop(context);
                                                Navigator.pushNamed(
                                                    context, 'wms-picking',
                                                    arguments: 0);
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
                                          child: const _ImteModule(
                                            urlImg: "picking.png",
                                            title: 'WMS Picking',
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        GestureDetector(
                                          onTap: () async {
                                            final String rol =
                                                await PrefUtils.getUserRol();

                                            if (rol == 'packing') {
                                              Navigator.pushNamed(
                                                  context, 'wms-packing');
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
                                          child: const _ImteModule(
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
                                        _ImteModule(
                                          urlImg: "inventario.png",
                                          title: 'WMS Conteo',
                                        ),
                                        SizedBox(width: 5),
                                        _ImteModule(
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

class _ItemList extends StatelessWidget {
  const _ItemList({
    required this.size,
    required this.color,
    required this.title,
    required this.value,
  });

  final Size size;
  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.6,
      child: Card(
        elevation: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.batch_prediction,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 5),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(value,
                style: TextStyle(
                    color: primaryColorApp,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}

class _ImteModule extends StatelessWidget {
  const _ImteModule({
    required this.urlImg,
    required this.title,
  });

  final String urlImg;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      child: SizedBox(
        width: 140,
        height: 160,
        child: Column(
          children: [
            Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(top: 10),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                // child: Image.network(urlImg, fit: BoxFit.cover),
                child: Image.asset("assets/icons/$urlImg", fit: BoxFit.cover)

                // CachedNetworkImage(
                //     progressIndicatorBuilder: (context, url, progress) => Center(
                //           child: CircularProgressIndicator(
                //             value: progress.progress,
                //           ),
                //         ),
                //     imageUrl: urlImg),

                ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  color: primaryColorApp,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Clipper para crear la forma de medio círculo
class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.arcToPoint(Offset(0.0, size.height * 0.5),
        radius: Radius.circular(size.width), clockwise: true);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
