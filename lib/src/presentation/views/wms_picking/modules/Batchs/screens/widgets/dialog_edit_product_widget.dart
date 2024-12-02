// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogEditProductWidget extends StatelessWidget {
  final ProductsBatch productsBatch;

  DialogEditProductWidget({super.key, required this.productsBatch});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: Center(
        child: Text("Editar Cantidad del Producto ",
            style: TextStyle(color: primaryColorApp, fontSize: 18)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.add, color: primaryColorApp, size: 20),
              const SizedBox(width: 5),
              const Text("Unidades:",
                  style: TextStyle(fontSize: 14, color: black)),
              const SizedBox(width: 5),
              Text(productsBatch.quantity.toString(),
                  style: const TextStyle(fontSize: 14, color: green)),
              const Spacer(),
              Icon(Icons.check, color: primaryColorApp, size: 20),
              const SizedBox(width: 5),
              const Text("Separadas:",
                  style: TextStyle(fontSize: 14, color: black)),
              const SizedBox(width: 5),
              Text(
                  productsBatch.quantitySeparate == null
                      ? "0"
                      : productsBatch.quantitySeparate.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: size.width,
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                          text: "¿Quiere completar la cantidad de ",
                          style: TextStyle(fontSize: 14, color: black)),
                      TextSpan(
                          text:
                              "${(productsBatch.quantity - productsBatch.quantitySeparate).toString()} ",
                          style: TextStyle(
                              fontSize: 14,
                              color: primaryColorApp,
                              fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "unidades? \n Para realizar una separacion completa del producto :",
                          style: TextStyle(fontSize: 14, color: black)),
                      TextSpan(
                          text: "${productsBatch.productId} ",
                          style:
                              TextStyle(fontSize: 14, color: primaryColorApp)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      //actualizar la cantidad separada en la bd
                      context.read<BatchBloc>().add(ChangeQuantitySeparate(
                          productsBatch.quantity ?? 0,
                          productsBatch.idProduct ?? 0,
                          productsBatch.idMove ?? 0));
                      //enviamos el producto a odoo
                      context
                          .read<BatchBloc>()
                          .add(SendProductEditOdooEvent(productsBatch));

                      Navigator.pop(context);

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColorApp,
                      minimumSize: Size(size.width * 0.93, 35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: BlocBuilder<BatchBloc, BatchState>(
                      builder: (context, state) {
                        if (state is LoadingSendProductEdit) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        }
                        return const Text(
                          'COMPLETAR CANTIDAD',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
