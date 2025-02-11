// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/packing_response_model.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/un_packing_request.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

class DialogUnPacking extends StatelessWidget {
  const DialogUnPacking({
    super.key,
    required this.product,
    required this.package,
  });

  final PorductoPedido product;
  final Paquete package;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: Colors.white,
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: 150,
              child: Image.asset(
                "assets/images/icono.jpeg",
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Esta seguro de desempacar el producto: ',
                      style: TextStyle(
                        color: primaryColorApp, // Color del texto principal
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${product.productId}', // Aquí iría el nombre del producto
                      style: const TextStyle(
                        color: red, // Color rojo para el nombre del producto
                        fontSize: 16,
                        fontWeight: FontWeight
                            .bold, // Puedes agregar negrita si lo deseas
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        )),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.center,
                child: Text(
                    "El producto sera desempacado y volvera al listado de por hacer.",
                    style: TextStyle(color: black, fontSize: 12))),
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
              final idOperario = await PrefUtils.getUserId();

              context.read<WmsPackingBloc>().add(UnPackingEvent(
                    UnPackingRequest(
                        idBatch: package.batchId ?? 0,
                        idPaquete: package.id ?? 0,
                        listItem: [
                          ListItemUnpack(
                              idMove: product.idMove ?? 0,
                              productId: product.idProduct ?? 0,
                              lote: product.loteId,
                              locationId: product.idLocation ?? 0,
                              cantidadSeparada: product.isCertificate == 0
                                  ? product.quantity ?? 0
                                  : product.quantitySeparate ?? 0,
                              observacion: "Desempacado",
                              idOperario: idOperario),
                        ]),
                    context,
                    product.pedidoId ?? 0,
                  ));

              Navigator.pop(context);
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
  }
}
