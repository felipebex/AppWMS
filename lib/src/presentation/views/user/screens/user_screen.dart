import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/environment/environment.dart';
import 'package:wms_app/src/presentation/views/home/index.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

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
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  final config = (state as ConfigurationLoaded).configurations;
                  return SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 10, top: 55, right: 10),
                      width: size.width,
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
                                              Navigator.pop(context);
                                            },
                                            icon: Icon(Icons.arrow_back,
                                                color: primaryColorApp,
                                                size: 30)),
                                      ),
                                      const SizedBox(width: 10),
                                      Text("Bienvenido a,  ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: primaryColorApp)),
                                      // Text('WMS',
                                      Text(Environment.flavor.appName,
                                          style: const TextStyle(
                                              fontSize: 18, color: black))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                              fontSize: 18,
                                              color: primaryColorApp)),
                                      // Text('WMS',
                                      Text(config.data?.result?.name ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 18, color: black))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Correo: ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: primaryColorApp)),
                                      // Text('WMS',
                                      Text(config.data?.result?.email ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 18, color: black))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Rol: ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: primaryColorApp)),
                                      // Text('WMS',
                                      Text(config.data?.result?.rol ?? '',
                                          style: const TextStyle(
                                              fontSize: 18, color: black))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text("Permisos:",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: primaryColorApp)),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Text("Ubicacion de origen manual: ",
                                              style: TextStyle(
                                                  fontSize: 16, color: black)),
                                          const Spacer(),
                                          Checkbox(
                                            
                                              value: config.data?.result
                                                      ?.locationPickingManual ??
                                                  false,
                                              onChanged: (value) {}),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Seleccionar Producto manual: ",
                                              style: TextStyle(
                                                  fontSize: 16, color: black)),
                                          const Spacer(),
                                          Checkbox(
                                              value: config.data?.result
                                                      ?.manualProductSelection ??
                                                  false,
                                              onChanged: (value) {}),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Seleccionar Cantidad manual: ",
                                              style: TextStyle(
                                                  fontSize: 16, color: black)),
                                          const Spacer(),
                                          Checkbox(
                                              value: config.data?.result
                                                      ?.manualQuantity ??
                                                  false,
                                              onChanged: (value) {}),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Seleccionar Muelle manual: ",
                                              style: TextStyle(
                                                  fontSize: 16, color: black)),
                                          const Spacer(),
                                          Checkbox(
                                              value: config.data?.result
                                                      ?.manualSpringSelection ??
                                                  false,
                                              onChanged: (value) {}),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Ver detalles picking: ",
                                              style: TextStyle(
                                                  fontSize: 16, color: black)),
                                          const Spacer(),
                                          Checkbox(
                                              value: config.data?.result
                                                      ?.showDetallesPicking ??
                                                  false,
                                              onChanged: (value) {}),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Ver proximas ubicaciones: ",
                                              style: TextStyle(
                                                  fontSize: 16, color: black)),
                                          const Spacer(),
                                          Checkbox(
                                              value: config.data?.result
                                                      ?.showDetallesPicking ??
                                                  false,
                                              onChanged: (value) {}),
                                        ],
                                      ),
                                      //checkbox
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }
}
