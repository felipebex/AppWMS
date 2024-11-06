import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab3Screen extends StatelessWidget {
  const Tab3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            width: double.infinity,
            height: size.height * 0.4,
            child: ListView.builder(
                itemCount: context.read<WmsPackingBloc>().productsDone.length,
                itemBuilder: (context, index) {
                  final product =
                      context.read<WmsPackingBloc>().productsDone[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'Packing',
                        );
                      },
                      child: Card(
                          color: product.isSeparate == 1
                              ? Colors.green[100]
                              : Colors.white,
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Column(
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Producto:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: primaryColorApp,
                                    ),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(" ${product.idProduct}",
                                        style: const TextStyle(
                                            fontSize: 16, color: black))),

                                Card(
                                  elevation: 3,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Cantidad: ",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text("${product.quantity}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: black)),
                                            const Spacer(),
                                            const Text(
                                              "Unidades: ",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text("${product.unidades}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: black)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              "Cantidades Separadas : ",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text("${product.quantitySeparate}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: black)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              "Novedades : ",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text("${product.observation}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: black)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                if (product.tracking != false)
                                  Row(
                                    children: [
                                      const Text(
                                        "Numero de serie/lote: ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: primaryColorApp,
                                        ),
                                      ),
                                      Text("${product.tracking}",
                                          style: const TextStyle(
                                              fontSize: 16, color: black)),
                                    ],
                                  ),

                                   Row(
                                    children: [
                                      const Text(
                                        "Peso: ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: primaryColorApp,
                                        ),
                                      ),
                                      Text("${product.weight}",
                                          style: const TextStyle(
                                              fontSize: 16, color: black)),
                                    ],
                                  ),
                                // if (product.expirationDate != false)
                                //   Row(
                                //     children: [
                                //       const Text(
                                //         "Fecha de caducidad: ",
                                //         style: TextStyle(
                                //           fontSize: 16,
                                //           color: primaryColorApp,
                                //         ),
                                //       ),
                                //       Text("${product.expirationDate}",
                                //           style: const TextStyle(
                                //               fontSize: 16, color: black)),
                                //     ],
                                //   )
                              ],
                            ),
                          )),
                    ),
                  );
                }),
          ),
          const Text("Listado de empaques",
              style: TextStyle(
                  fontSize: 16,
                  color: primaryColorApp,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 55),
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.white,
                    child: ExpansionTile(
                      title: Text('Empaque ${index + 1}'),
                      children: [
                        ListTile(
                          title: Text('Detalles de: ${[index]}'),
                          subtitle:
                              const Text('Cantidad: 1'), // Puedes ajustar esto
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
