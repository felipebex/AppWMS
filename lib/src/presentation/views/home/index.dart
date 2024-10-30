// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/global/login/models/user_model.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';

import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    UserModel user = await PrefUtils.getUser();
    setState(() {
      userName =
          user.name ?? 'Usuario'; // Fallback en caso de que no haya nombre
    });
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
          if (state is HomeLoadedState) {
            context.read<WMSPickingBloc>().add(LoadAllBatchsEvent(context));
          }
        },
        builder: (context, state) {
          return Scaffold(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.only(left: 20, top: 60),
                            width: size.width,
                            height: 140,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text("Bienvenido a, ",
                                            style: TextStyle(
                                                fontSize: 18, color: white)),
                                        Text('WMS',
                                            style: TextStyle(
                                                fontSize: 18, color: white))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("Hola, ",
                                            style: TextStyle(
                                                fontSize: 20, color: white)),
                                        SizedBox(
                                          width: size.width * 0.6,
                                          child: Text(
                                            userName,
                                            style: TextStyle(
                                                color: Colors.amber[200],
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
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
                                              title: const Center(
                                                  child: Text('Cerrar sesión',
                                                      style: TextStyle(
                                                          color:
                                                              primaryColorApp))),
                                              content: const Text(
                                                  '¿Estás seguro de que deseas cerrar sesión?'),
                                              actions: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize:
                                                        const Size(100, 40),
                                                    backgroundColor: grey,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize:
                                                        const Size(100, 40),
                                                    backgroundColor:
                                                        primaryColorApp,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                            (route) => false);
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
                                    margin: const EdgeInsets.only(right: 20),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Icon(Icons.logout,
                                        color: primaryColorApp),
                                  ),
                                )
                              ],
                            )),
                        Center(
                          child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              width: size.width,
                              height: 50,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _ItemList(
                                    size: size,
                                    color: green,
                                    title: 'BATCH Hechos',
                                    value: context
                                        .read<HomeBloc>()
                                        .countBatchDone
                                        .toString(),
                                  ),
                                  _ItemList(
                                    size: size,
                                    color: primaryColorApp,
                                    title: 'BATCH En Proceso',
                                    value: context
                                        .read<HomeBloc>()
                                        .countBatchInProgress
                                        .toString(),
                                  ),
                                  _ItemList(
                                    size: size,
                                    color: Colors.amber,
                                    title: 'BATCH Totales',
                                    value: context
                                        .read<HomeBloc>()
                                        .countBatchAll
                                        .toString(),
                                  ),
                                ],
                              )),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<WMSPickingBloc>()
                                            .add(LoadBatchsFromDBEvent());
                                        Navigator.pushNamed(
                                            context, 'wms-picking');
                                      },
                                      child: const _ImteModule(
                                        urlImg: "picking.png",
                                        title: 'WMS Picking',
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, 'wms-packing');
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                ],
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
                style: const TextStyle(
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
              style: const TextStyle(
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
