// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/presentation/views/home/widgets/widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/widgets/dialog_info_widget.dart';
import 'package:wms_app/src/services/preferences.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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
              BlocListener<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is AppVersionUpdateState) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return UpdateAppDialog();
                        });
                  }

                  if (state is AppVersionLoadedState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("No hay actualizaciones disponibles"),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    final config = context.read<UserBloc>().configurations;
                    return SizedBox(
                      width: size.width,
                      height: size.height,
                      child: Container(
                        padding:
                            const EdgeInsets.only(left: 10, top: 35, right: 10),
                        width: size.width,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Card(
                                color: white,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Card(
                                            color: white,
                                            elevation: 2,
                                            child: IconButton(
                                                onPressed: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, 'home');
                                                },
                                                icon: Icon(Icons.arrow_back,
                                                    color: primaryColorApp,
                                                    size: 30)),
                                          ),
                                          const SizedBox(width: 10),
                                          Text("Bienvenido a,  ",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp)),
                                          // Text('WMS',
                                          Text('OnPoint',
                                              style: const TextStyle(
                                                  fontSize: 14, color: black))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                color: white,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<HomeBloc>()
                                          .add(AppVersionEvent(context));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 30),
                                        backgroundColor: grey),
                                    child: const Text(
                                      "Comprobar actualizaciones",
                                      style: TextStyle(color: white),
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                color: white,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text("Nombre: ",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp)),
                                          // Text('WMS',
                                          Text(
                                              config.result?.result?.name ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 14, color: black))
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Correo: ",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: primaryColorApp)),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.9,
                                        child: Text(
                                            config.result?.result?.email ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 14, color: black)),
                                      ),
                                      Row(
                                        children: [
                                          Text("Rol: ",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp)),
                                          // Text('WMS',
                                          Text(config.result?.result?.rol ?? '',
                                              style: const TextStyle(
                                                  fontSize: 14, color: black))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text("Version App: ",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp)),
                                          // Text('WMS',
                                          Text(
                                              context
                                                  .read<UserBloc>()
                                                  .versionApp,
                                              style: const TextStyle(
                                                  fontSize: 14, color: black))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text("Url: ",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp)),
                                          // Text('WMS',
                                          Text(
                                              Preferences.urlWebsite.toString(),
                                              style: const TextStyle(
                                                  fontSize: 14, color: black))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text("DataBase: ",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp)),
                                          // Text('WMS',
                                          Text(
                                              Preferences.nameDatabase
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 14, color: black))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                  color: white,
                                  elevation: 2,
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Text("Informacion PDA:",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColorApp)),
                                          ),
                                          Row(
                                            children: [
                                              Text("Modelo: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: primaryColorApp)),
                                              // Text('WMS',
                                              Text(
                                                  context
                                                      .read<UserBloc>()
                                                      .modelo,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: black))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text("Version: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: primaryColorApp)),
                                              // Text('WMS',
                                              Text(
                                                  context
                                                      .read<UserBloc>()
                                                      .version,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: black))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text("Fabricante: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: primaryColorApp)),
                                              // Text('WMS',
                                              Text(
                                                  context
                                                      .read<UserBloc>()
                                                      .fabricante,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: black))
                                            ],
                                          ),
                                        ],
                                      ))),
                              const SizedBox(height: 20),
                              Card(
                                elevation: 2,
                                color: white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: size.width,
                                    height: 350,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Text("Permisos Picking:",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColorApp)),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Text(
                                                  "Ubicacion de origen: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.locationPickingManual ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Ubicacion de origen manual",
                                                            body:
                                                                "Permite seleccionar la ubicacion de origen en el proceso del picking de forma manual",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                  "Seleccionar Producto: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.manualProductSelection ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Seleccionar Producto manual",
                                                            body:
                                                                "Permite seleccionar el producto en el proceso del picking de forma manual",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                  "Seleccionar Cantidad: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.manualQuantity ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Seleccionar Cantidad manual",
                                                            body:
                                                                "Permite seleccionar la cantidad en el proceso del picking de forma manual",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Seleccionar Muelle: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.manualSpringSelection ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Seleccionar Muelle manual",
                                                            body:
                                                                "Permite seleccionar el muelle en el proceso del picking de forma manual",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                  "Ver detalles picking: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.showDetallesPicking ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Ver detalles picking",
                                                            body:
                                                                "Permite ver los detalles del picking de manera mas detallada, como la cantidad de productos, ubicaciones, etc.",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                  "Ver proximas ubicaciones: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.showNextLocationsInDetails ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Ver proximas ubicaciones",
                                                            body:
                                                                "Permite ver las proximas ubicaciones a las que se debe dirigir el operario para completar el picking",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Center(
                                            child: Text("Permisos Packing:",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColorApp)),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Text(
                                                  "Ubicacion de origen: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.locationPackManual ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Ubicacion de origen manual",
                                                            body:
                                                                "Permite seleccionar la ubicacion de origen en el proceso del packing de forma manual",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                  "Seleccionar Producto: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.manualProductSelectionPack ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Seleccionar Producto manual",
                                                            body:
                                                                "Permite seleccionar el producto en el proceso del packing de forma manual",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                  "Seleccionar Cantidad: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.manualQuantityPack ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Seleccionar Cantidad manual",
                                                            body:
                                                                "Permite seleccionar la cantidad en el proceso del packing de forma manual",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Seleccionar Muelle: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.manualSpringSelectionPack ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Seleccionar Muelle manual",
                                                            body:
                                                                "Permite seleccionar el muelle en el proceso del packing de forma manual",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Escanear producto: ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: black)),
                                              const Spacer(),
                                              Checkbox(
                                                  value: config.result?.result
                                                          ?.scanProduct ??
                                                      false,
                                                  onChanged: null),
                                              IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return const DialogInfo(
                                                            title:
                                                                "Escanear producto para packing",
                                                            body:
                                                                "Permite escanear el producto en el proceso del packing desde la lista de por hacer",
                                                          );
                                                        });
                                                  },
                                                  icon: Icon(Icons.help,
                                                      color: primaryColorApp))
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  //modal de confirmacion
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          title: Center(
                                              child: Text(
                                                  "Eliminar Base de Datos",
                                                  style: TextStyle(
                                                      color: primaryColorApp,
                                                      fontSize: 14))),
                                          content: const Text(
                                              "¿Estas seguro de eliminar la base de datos?\nEsta accion no se puede deshacer y perderas todo el progreso que llevas realizado y esta guardado en la base de datos",
                                              style: TextStyle(
                                                  fontSize: 12, color: black)),
                                          actions: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: grey),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Cancelar",
                                                    style: TextStyle(
                                                        color: white))),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  await DataBaseSqlite()
                                                      .deleteBD();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                        "Base de datos eliminada correctamente"),
                                                  ));
                                                  Navigator.pop(context);
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, 'home');
                                                },
                                                child: const Text("Aceptar")),
                                          ],
                                        );
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: grey),
                                child: const Text(
                                  "Eliminar Base de Datos",
                                  style: TextStyle(color: white),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
