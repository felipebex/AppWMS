// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab1Screen extends StatelessWidget {
  const Tab1Screen({
    super.key,
    required this.size,
    required this.packingModel,
  });

  final Size size;
  final PedidoPacking? packingModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WmsPackingBloc, WmsPackingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: white,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: AlertDialog(
                        backgroundColor: Colors.white,
                        actionsAlignment: MainAxisAlignment.center,
                        title: const Text(
                          'Confirmar pedido',
                          style:
                              TextStyle(color: primaryColorApp, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 200,
                              child: Image.asset(
                                "assets/images/icono.jpeg",
                                fit: BoxFit.cover,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                '¿Estás seguro de confirmar el pedido y dejarlo listo para ser enviado?',
                                style: TextStyle(color: black, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await DataBaseSqlite()
                                  .getFieldTablePedidosPacking(
                                      packingModel?.batchId ?? 0,
                                      packingModel?.id ?? 0,
                                      "is_terminate",
                                      "true");

                              context
                                  .read<WmsPackingBloc>()
                                  .add(LoadAllPedidosFromBatchEvent(
                                    packingModel?.batchId ?? 0,
                                  ));

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColorApp,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
            backgroundColor: primaryColorApp,
            child: const Icon(Icons.check, color: white),
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Detalles del pedido",
                style: TextStyle(
                    fontSize: 18, color: black, fontWeight: FontWeight.bold),
              ),

              //detalles del batch
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              packingModel?.name ?? '',
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: primaryColorApp,
                                  fontWeight: FontWeight.bold),
                            )),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Contacto: ',
                              style: TextStyle(fontSize: 14, color: black),
                            )),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              packingModel?.contacto ?? '',
                              style: const TextStyle(
                                  fontSize: 14, color: primaryColorApp),
                            )),
                        Row(
                          children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Fecha programada:",
                                  style: TextStyle(fontSize: 14, color: black),
                                )),
                            const SizedBox(width: 10),
                            Builder(
                              builder: (context) {
                                // Verifica si `scheduledDate` es false o null
                                String displayDate;
                                if (packingModel?.fecha == false ||
                                    packingModel?.fecha == null) {
                                  displayDate = 'sin fecha';
                                } else {
                                  try {
                                    DateTime dateTime = DateTime.parse(
                                      packingModel?.fecha.toString() ?? '',
                                    ); // Parsear la fecha
                                    // Formatear la fecha usando Intl
                                    displayDate =
                                        DateFormat('dd MMMM yyyy', 'es_ES')
                                            .format(dateTime);
                                  } catch (e) {
                                    displayDate =
                                        'sin fecha'; // Si ocurre un error al parsear
                                  }
                                }
                                return SizedBox(
                                  width: size.width * 0.55,
                                  child: Text(
                                    displayDate,
                                    style: const TextStyle(
                                        fontSize: 14, color: primaryColorApp),
                                    textAlign: TextAlign.left,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Numero de productos: ',
                                  style: TextStyle(fontSize: 14, color: black),
                                )),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  context
                                      .read<WmsPackingBloc>()
                                      .listOfProductos
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 14, color: primaryColorApp),
                                )),
                          ],
                        ),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Tipo de operacion: ',
                              style: TextStyle(fontSize: 14, color: black),
                            )),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              packingModel?.tipoOperacion ?? "",
                              style: const TextStyle(
                                  fontSize: 14, color: primaryColorApp),
                            )),
                        Row(
                          children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Numero de paquetes: ',
                                  style: TextStyle(fontSize: 14, color: black),
                                )),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  context
                                      .read<WmsPackingBloc>()
                                      .packages
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 14, color: primaryColorApp),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Text("Listado de empaques",
                  style: TextStyle(
                      fontSize: 16,
                      color: primaryColorApp,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: (context.read<WmsPackingBloc>().packages.isEmpty)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/empty.png',
                                  height:
                                      150), // Ajusta la altura según necesites
                              const SizedBox(height: 10),
                              const Text('No hay empaques',
                                  style: TextStyle(fontSize: 18, color: grey)),
                              const Text('Realiza el proceso de empaque',
                                  style: TextStyle(fontSize: 14, color: grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 55),
                          itemCount:
                              context.read<WmsPackingBloc>().packages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final package =
                                context.read<WmsPackingBloc>().packages[index];

                            // Filtrar los productos de acuerdo al id_package del paquete actual
                            final filteredProducts = context
                                .read<WmsPackingBloc>()
                                .listOfProductos
                                .where((product) =>
                                    product.idPackage == package.id)
                                .toList();

                            return Card(
                              color: Colors.white,
                              child: ExpansionTile(
                                childrenPadding: const EdgeInsets.all(10),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${package.name}",
                                      style: const TextStyle(
                                          fontSize: 14, color: primaryColorApp),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Cantidad de productos: ${package.cantidadProductos}",
                                          style: const TextStyle(
                                              fontSize: 14, color: black),
                                        ),
                                        const Spacer(),
                                        if (package.isSticker == true)
                                          IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.print,
                                                color: primaryColorApp,
                                                size: 20,
                                              ))
                                      ],
                                    ),
                                  ],
                                ),
                                children: [
                                  // Aquí generamos la lista de productos filtrados
                                  SizedBox(
                                    width: double.infinity,
                                    height: 150,
                                    child: ListView.builder(
                                      itemCount: filteredProducts
                                          .length, // La cantidad de productos filtrados
                                      itemBuilder: (context, index) {
                                        final product = filteredProducts[index];
                                        return Card(
                                          color: white,
                                          elevation: 2,
                                          child: ListTile(
                                            title: Text(product.idProduct ?? "",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        black)), // Muestra el nombre del producto
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        style: const TextStyle(
                                                          fontSize:
                                                              14, // Tamaño del texto
                                                          color: Colors
                                                              .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                        ),
                                                        children: <TextSpan>[
                                                          const TextSpan(
                                                              text:
                                                                  "Cantidad separada: ",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)), // Parte del texto en color negro (o el color que prefieras)
                                                          TextSpan(
                                                            text:
                                                                "${product.quantitySeparate}", // La cantidad en color rojo
                                                            style: const TextStyle(
                                                                color:
                                                                    primaryColorApp,
                                                                fontSize:
                                                                    12), // Estilo solo para la cantidad
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    RichText(
                                                      text: TextSpan(
                                                        style: const TextStyle(
                                                          fontSize:
                                                              14, // Tamaño del texto
                                                          color: Colors
                                                              .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                        ),
                                                        children: <TextSpan>[
                                                          const TextSpan(
                                                              text:
                                                                  "Unidades: ",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)), // Parte del texto en color negro (o el color que prefieras)
                                                          TextSpan(
                                                            text:
                                                                "${product.unidades}", // La cantidad en color rojo
                                                            style: const TextStyle(
                                                                color:
                                                                    primaryColorApp,
                                                                fontSize:
                                                                    12), // Estilo solo para la cantidad
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        style: const TextStyle(
                                                          fontSize:
                                                              14, // Tamaño del texto
                                                          color: Colors
                                                              .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                        ),
                                                        children: <TextSpan>[
                                                          const TextSpan(
                                                              text:
                                                                  "Cantidad solicitada: ",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)), // Parte del texto en color negro (o el color que prefieras)
                                                          TextSpan(
                                                            text:
                                                                "${product.quantity}", // La cantidad en color rojo
                                                            style: const TextStyle(
                                                                color:
                                                                    primaryColorApp,
                                                                fontSize:
                                                                    12), // Estilo solo para la cantidad
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    RichText(
                                                      text: TextSpan(
                                                        style: const TextStyle(
                                                          fontSize:
                                                              14, // Tamaño del texto
                                                          color: Colors
                                                              .black, // Color del texto por defecto (puedes cambiarlo aquí)
                                                        ),
                                                        children: <TextSpan>[
                                                          const TextSpan(
                                                              text: "Peso: ",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      black)), // Parte del texto en color negro (o el color que prefieras)
                                                          TextSpan(
                                                            text:
                                                                "${product.weight}", // La cantidad en color rojo
                                                            style: const TextStyle(
                                                                color:
                                                                    primaryColorApp,
                                                                fontSize:
                                                                    12), // Estilo solo para la cantidad
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ), // Muestra la cantidad
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (package.isSticker == true)
                                    ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            minimumSize: Size(size.width, 35),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.print),
                                            SizedBox(width: 10),
                                            Text(
                                              "Imprimir sticker",
                                              style: TextStyle(color: black),
                                            )
                                          ],
                                        )),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
