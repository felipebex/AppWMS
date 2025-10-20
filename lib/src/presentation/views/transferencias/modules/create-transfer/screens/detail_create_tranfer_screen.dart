import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/transferencias/modules/create-transfer/bloc/crate_transfer_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';

class DetailCreateTransferScreen extends StatelessWidget {
  const DetailCreateTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<CreateTransferBloc, CreateTransferState>(
      listener: (context, state) {
        if (state is ProductRemovingFromTransferLoadingState) {
          //mostrar loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: CircularProgressIndicator(
                  color: primaryColorApp,
                ),
              );
            },
          );
        } else if (state is ProductRemovedFromTransferState) {
          //ocultar loading
          Navigator.of(context).pop();
          //mostrar mensaje de éxito
          Get.snackbar(
            '360 Software Informa',
            'Producto eliminado de la transferencia',
            backgroundColor: Colors.green,
            colorText: white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else if (state is ProductRemoveFromTransferErrorState) {
          //ocultar loading
          Navigator.of(context).pop();
          //mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: white,
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                //*AppBar
                Container(
                  decoration: BoxDecoration(
                    color: primaryColorApp,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  width: double.infinity,
                  child: BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                      builder: (context, status) {
                    return Column(
                      children: [
                        const WarningWidgetCubit(),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: 0,
                              top: status != ConnectionStatus.online ? 0 : 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.arrow_back, color: white),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, 'create-transfer');
                                },
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: size.width * 0.25),
                                child: const Text("DETALLES",
                                    style:
                                        TextStyle(color: white, fontSize: 18)),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Total de productos: ",
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColorApp,
                              ),
                            ),
                            Text(
                                "${context.read<CreateTransferBloc>().productosCreateTransfer.length}",
                                style: const TextStyle(
                                    fontSize: 14, color: black)),
                          ],
                        ),

                        //ubicacion de origen
                        Row(
                          children: [
                            Text(
                              "Ubicación de origen: ",
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColorApp,
                              ),
                            ),
                            Text("location",
                                style: const TextStyle(
                                    fontSize: 14, color: black)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Ubicación destino: ",
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColorApp,
                              ),
                            ),
                            Text("location",
                                style: const TextStyle(
                                    fontSize: 14, color: black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Center(
                  child: Text(
                    "Productos agregados",
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryColorApp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                (context
                        .read<CreateTransferBloc>()
                        .productosCreateTransfer
                        .isEmpty)
                    ? Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text('No hay transferencias',
                                style: TextStyle(fontSize: 14, color: grey)),
                            const Text('Intente buscar otra transferencia',
                                style: TextStyle(fontSize: 12, color: grey)),
                            Visibility(
                              visible: context
                                  .read<UserBloc>()
                                  .fabricante
                                  .contains("Zebra"),
                              child: Container(
                                height: 60,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                        padding: const EdgeInsets.only(top: 0),
                        itemBuilder: (context, index) {
                          final product = context
                              .read<CreateTransferBloc>()
                              .productosCreateTransfer[index];
                          return Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 5),
                              child: Card(
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Producto:",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                //dialogo de confirmcion de eliminar
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: Center(
                                                        child: const Text(
                                                          'Eliminar producto',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Text(
                                                            '¿Está seguro de que desea eliminar este producto?',
                                                            style: TextStyle(
                                                                color: black),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: <Widget>[
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                grey,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Cancelar',
                                                            style: TextStyle(
                                                                color: white),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            context
                                                                .read<
                                                                    CreateTransferBloc>()
                                                                .add(
                                                                  RemoveProductFromTransferEvent(
                                                              
                                                                          product),
                                                                );
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                primaryColorApp,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Eliminar',
                                                            style: TextStyle(
                                                                color: white),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${product.name}",
                                            style: const TextStyle(
                                                fontSize: 12, color: black),
                                          ),
                                        ),
                                        Visibility(
                                          visible: product.tracking == 'lot',
                                          child: Row(
                                            children: [
                                              Text(
                                                "Lote: ",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: primaryColorApp,
                                                ),
                                              ),
                                              Text("${product.lotName}",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: black)),
                                              // Text("/${product.loteDate}",
                                              //     style: const TextStyle(
                                              //         fontSize: 12,
                                              //         color: black)),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Barcode: ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${product.barcode}",
                                                style: const TextStyle(
                                                    fontSize: 12, color: black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Código: ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${product.code}",
                                                style: const TextStyle(
                                                    fontSize: 12, color: black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Cantidad: ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                product.quantityDone == null
                                                    ? "0.0"
                                                    : "${product.quantityDone}",
                                                style: const TextStyle(
                                                    fontSize: 12, color: black),
                                              ),
                                            ),
                                            const Spacer(),
                                            //unidad
                                            Text(
                                              "${product.uom}",
                                              style: const TextStyle(
                                                  fontSize: 12, color: black),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Tiempo: ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: primaryColorApp,
                                              ),
                                            ),
                                            Text(
                                                convertirTiempo(
                                                    product.time.toString()),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: black)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )));
                        },
                        itemCount: context
                            .read<CreateTransferBloc>()
                            .productosCreateTransfer
                            .length,
                      )),
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(size.width * 0.8, 40),
                      backgroundColor: primaryColorApp,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('CREAR TRANSFERENCIA',
                        style: TextStyle(color: white))),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  String convertirTiempo(String tiempoStr) {
    // Convertimos el string a un double
    double segundos = double.tryParse(tiempoStr) ?? 0.0;
    // Calculamos horas, minutos y segundos
    int horas = (segundos / 3600).floor(); // 3600 segundos = 1 hora
    int minutos =
        ((segundos % 3600) / 60).floor(); // Resto de segundos dividido entre 60
    int segundosRestantes = (segundos % 60).round(); // Resto de segundos
    // Formateamos los valores en 2 dígitos (ej. 01, 02, etc.)
    String horasStr = horas.toString().padLeft(2, '0');
    String minutosStr = minutos.toString().padLeft(2, '0');
    String segundosStr = segundosRestantes.toString().padLeft(2, '0');

    return '$horasStr:$minutosStr:$segundosStr';
  }
}
