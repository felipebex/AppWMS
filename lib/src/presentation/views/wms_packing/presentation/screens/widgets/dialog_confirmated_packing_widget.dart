// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogConfirmatedPacking extends StatelessWidget {
  const DialogConfirmatedPacking({
    super.key, required this.productos, required this.isCertificate,
  });

  final List<PorductoPedido> productos;
  final bool isCertificate;

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
              width: 200,
              child: Image.asset(
                "assets/images/icono.jpeg",
                fit: BoxFit.cover,
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Esta seguro de empacar los productos seleccionados?',
                style: TextStyle(color: primaryColorApp, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<WmsPackingBloc, WmsPackingState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //icono de sticker
                    Checkbox(
                      value: context.read<WmsPackingBloc>().isSticker,
                      onChanged: (value) {
                        context.read<WmsPackingBloc>().add(ChangeStickerEvent(
                            !context.read<WmsPackingBloc>().isSticker, ));
                      },
                    ),
                    const Icon(Icons.print, color: primaryColorApp),
                    const SizedBox(width: 10),
                    const Text(
                      'Incluir sticker de certificación',
                      style: TextStyle(color: black),
                    ),
                  ],
                );
              },
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
            onPressed: () {

              context.read<WmsPackingBloc>().add(SetPackingsEvent(
                    productos,
                    context.read<WmsPackingBloc>().isSticker,
                    isCertificate,
                  ));
              
                context.read<WmsPackingBloc>().add(ChangeStickerEvent(false));
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
