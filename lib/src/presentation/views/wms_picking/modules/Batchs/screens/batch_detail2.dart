import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class BatchDetail2Screen extends StatelessWidget {
  const BatchDetail2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Ejemplo de valores
    int completedTasks = 1;
    int totalTasks = 3;
    double progress = completedTasks / totalTasks; // Calcula el progreso

    return BlocBuilder<BatchBloc, BatchState>(builder: (context, state) {
      print("State 💩: $state");
// LoadProductsBatchSuccesState
      if (state is LoadProductsBatchSuccesStateBD) {
        final currentProduct = context.read<BatchBloc>().currentProduct;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(top: 50),
                  width: size.width,
                  height: 160,
                  color: primaryColorApp,
                  child: Column(
                    children: [
                      AppBarInfo(
                        currentProduct: currentProduct ?? ProductsBatch(),
                      ),
                      const SizedBox(height: 10),
                      ProgressIndicatorWidget(
                        progress: progress,
                        completed: completedTasks,
                        total: totalTasks,
                      ),
                    ],
                  )),
              Expanded(
                child: ListView(children: [
                  ItemCard(
                    title: 'Ubicación de origen',
                    subtitle: currentProduct?.locationId ?? '',
                    color: green,
                    isContent: false,
                    isBtn: false,
                  ),
                  ItemCard(
                    title: 'Producto',
                    subtitle: currentProduct?.productId ?? '',
                    color: yellow,
                    isContent: false,
                    isBtn: true,
                  ),
                  ItemCard(
                    title: 'Ubicacion de destino',
                    subtitle: currentProduct?.locationDestId ?? '',
                    color: grey,
                    isContent: false,
                    isBtn: true,
                  ),
                ]),
              ),
              Quantity(
                size: size,
                currentProduct: currentProduct ?? ProductsBatch(),
              ),
            ],
          ),
        );
      }
      if (state is ProductsBatchLoadingState) {
        return const Scaffold(
          backgroundColor: primaryColorApp,
          body: Center(
            child: FlutterLogo(size: 100),
          ),
        );
      }

      return const Scaffold(
        body: Center(
          child: Text('Error al cargar los productos'),
        ),
      );
    });
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.contenido,
    required this.color,
    required this.isContent,
    required this.isBtn,
  });

  final String title;
  final String subtitle;
  final String? contenido;
  final Color color;
  final bool isContent;
  final bool isBtn;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Row(
      children: [
        //hacemos un punto de color
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Card(
          color: Colors.white,
          elevation: 5,
          child: Container(
            width: size.width * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(fontSize: 16, color: primaryColorApp),
                    ),
                    const Spacer(),
                    if (isBtn)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_note_sharp,
                            color: primaryColorApp, size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(subtitle,
                    style: const TextStyle(fontSize: 18, color: black)),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class AppBarInfo extends StatelessWidget {
  const AppBarInfo({
    super.key,
    required this.currentProduct,
  });

  final ProductsBatch currentProduct;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        return Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.read<BatchBloc>().batchWithProducts.batch?.name ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 26),
              ),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              shadowColor: Colors.white,
              color: Colors.white,
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
              onSelected: (String value) {
                // Manejar la selección de opciones aquí
                if (value == '1') {
                  // Acción para opción 1
                } else if (value == '2') {
                  // Acción para opción 2
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: AlertDialog(
                            backgroundColor: Colors.white,
                            actionsAlignment: MainAxisAlignment.center,
                            title: const Center(
                                child: Text('Dejar pendiente',
                                    style: TextStyle(color: primaryColorApp))),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Text(
                                      '¿Estás seguro de dejar pendiente este producto?'),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 3),
                                  child: const Text('Cancelar',
                                      style:
                                          TextStyle(color: primaryColorApp))),
                              ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColorApp,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: const Text('Aceptar',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ))),
                            ],
                          ),
                        );
                      });
                }
                // Agrega más opciones según sea necesario
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: '1',
                    child: Row(
                      children: [
                        Icon(Icons.info, color: primaryColorApp, size: 20),
                        SizedBox(width: 10),
                        Text('Ver detalles'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: '2',
                    child: Row(
                      children: [
                        Icon(Icons.timelapse_rounded,
                            color: primaryColorApp, size: 20),
                        SizedBox(width: 10),
                        Text('Dejar pendiente'),
                      ],
                    ),
                  ),
                  // Agrega más PopupMenuItems aquí
                ];
              },
            ),
          ],
        );
      },
    );
  }
}

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress; // Valor de progreso (0.0 a 1.0)
  final int completed; // Cantidad completada
  final int total; // Cantidad total

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea de progreso
        LinearProgressIndicator(
          value: progress, // Progreso entre 0.0 y 1.0
          minHeight: 5, // Altura de la barra
          backgroundColor: Colors.grey[300], // Color de fondo
          valueColor:
              const AlwaysStoppedAnimation<Color>(green), // Color de la barra
        ),
        const SizedBox(height: 10), // Espaciado entre la barra y el texto
        // Texto de progreso
        Align(
          alignment: Alignment.center,
          child: Text(
            'Hecho $completed / Por hacer $total',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class Quantity extends StatelessWidget {
  const Quantity({
    super.key,
    required this.size,
    required this.currentProduct,
  });

  final Size size;
  final ProductsBatch currentProduct;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatchBloc, BatchState>(builder: (context, state) {
      return SizedBox(
        width: size.width,
        height: 150,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white,
                elevation: 5,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Center(
                    child: Row(
                      children: [
                        const Text('Recoger:',
                            style:
                                TextStyle(color: Colors.black, fontSize: 26)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            currentProduct.quantity.toString(),
                            style: const TextStyle(
                                color: primaryColorApp, fontSize: 26),
                          ),
                        ),
                        const Text('UND',
                            style:
                                TextStyle(color: Colors.black, fontSize: 26)),
                        const Icon(Icons.question_mark),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('0',
                              style: TextStyle(
                                  color: primaryColorApp, fontSize: 26)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColorApp,
                  minimumSize: Size(size.width * 1, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'APLICAR CANTIDAD',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    });
  }
}

class NumericKeyboard extends StatelessWidget {
  final List<List<String>> keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', 'C'],
  ];

  NumericKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3, // 3 columnas
      childAspectRatio: 2.5, // Ajusta la proporción del botón
      padding: const EdgeInsets.all(5.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      children: List.generate(keys.length * keys[0].length, (index) {
        String key = keys[index ~/ 3][index % 3]; // Calcula la clave
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            // Aquí puedes manejar lo que sucede al presionar el botón
            print(key);
          },
          child: Text(key, style: TextStyle(fontSize: 26, color: black)),
        );
      }),
    );
  }
}
