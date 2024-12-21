// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';

import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/widgets/jeyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class DialogEditProductWidget extends StatefulWidget {
  final ProductsBatch productsBatch;

  DialogEditProductWidget({
    super.key,
    required this.productsBatch,
  });

  @override
  State<DialogEditProductWidget> createState() =>
      _DialogEditProductWidgetState();
}

class _DialogEditProductWidgetState extends State<DialogEditProductWidget> {
  String alerta = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: Center(
        child: Text(
            "Editar Cantidad del Producto\n${widget.productsBatch.productId}",
            textAlign: TextAlign.center,
            style: TextStyle(color: primaryColorApp, fontSize: 16)),
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
              Text(widget.productsBatch.quantity.toString(),
                  style: const TextStyle(fontSize: 14, color: green)),
              const Spacer(),
              Icon(Icons.check, color: primaryColorApp, size: 20),
              const SizedBox(width: 5),
              const Text("Separadas:",
                  style: TextStyle(fontSize: 14, color: black)),
              const SizedBox(width: 5),
              Text(
                  widget.productsBatch.quantitySeparate == null
                      ? "0"
                      : widget.productsBatch.quantitySeparate.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    const TextSpan(
                        text: "La cantidad a completar es de ",
                        style: TextStyle(fontSize: 14, color: black)),
                    TextSpan(
                        text:
                            "${(widget.productsBatch.quantity - widget.productsBatch.quantitySeparate).toString()} ",
                        style: TextStyle(
                            fontSize: 14,
                            color: primaryColorApp,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: context.read<BatchBloc>().editProductController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Solo permite dígitos
                  ],
                  decoration: InputDecorations.authInputDecoration(
                    hintText: 'Cantidad',
                    labelText: 'Cantidad',
                    suffixIconButton: IconButton(
                      onPressed: () {
                        context.read<BatchBloc>().editProductController.clear();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: primaryColorApp,
                        size: 20,
                      ),
                    ),
                  ),
                  onChanged: context
                          .read<UserBloc>()
                          .fabricante
                          .contains("Zebra")
                      ? null
                      : (value) {
                          context.read<BatchBloc>().editProductController.text =
                              value;
                          if (value.isNotEmpty) {
                            int cantidad = int.parse(value);
                            if (cantidad == 0) {
                              context
                                  .read<BatchBloc>()
                                  .editProductController
                                  .clear();
                              setState(() {
                                alerta = "La cantidad no puede ser 0";
                              });
                            } else if (cantidad >
                                (widget.productsBatch.quantity -
                                    widget.productsBatch.quantitySeparate)) {
                              context
                                  .read<BatchBloc>()
                                  .editProductController
                                  .clear();
                              setState(() {
                                alerta =
                                    "La cantidad no puede ser mayor a la cantidad restante";
                              });
                            } else {
                              setState(() {
                                alerta = "";
                              });
                            }
                          }
                        },
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(alerta,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12))),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: context
                            .read<BatchBloc>()
                            .editProductController
                            .text
                            .isEmpty
                        ? null
                        : () async {
                            int cantidad = int.parse(context
                                    .read<BatchBloc>()
                                    .editProductController
                                    .text
                                    .isEmpty
                                ? "0"
                                : context
                                    .read<BatchBloc>()
                                    .editProductController
                                    .text);

                            if (cantidad == 0) {
                              setState(() {
                                alerta = "La cantidad no puede ser 0";
                              });
                              return;
                            } else if (cantidad >
                                (widget.productsBatch.quantity -
                                    widget.productsBatch.quantitySeparate)) {
                              setState(() {
                                alerta =
                                    "La cantidad no puede ser mayor a la cantidad restante";
                              });
                              return;
                            } else {
                              final int cantidadReuqest =
                                  ((widget.productsBatch.quantitySeparate ??
                                          0) +
                                      cantidad);
                              //actualizar la cantidad separada en la bd
                              context.read<BatchBloc>().add(
                                  ChangeQuantitySeparate(
                                      cantidadReuqest,
                                      widget.productsBatch.idProduct ?? 0,
                                      widget.productsBatch.idMove ?? 0));

                              context
                                  .read<BatchBloc>()
                                  .add(SendProductEditOdooEvent(
                                    widget.productsBatch,
                                    cantidadReuqest,
                                  ));

                              Navigator.pop(context);
                            }
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
                          'AGREGAR CANTIDAD',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        );
                      },
                    ),
                  ),
                ),
                CustomKeyboardNumber(
                  controller: context.read<BatchBloc>().editProductController,
                  onchanged: () {
                    final value =
                        context.read<BatchBloc>().editProductController.text;
                    if (value.isNotEmpty) {
                      int cantidad = int.parse(value);
                      if (cantidad == 0) {
                        setState(() {
                          alerta = "La cantidad no puede ser 0";
                        });
                      } else if (cantidad >
                          (widget.productsBatch.quantity -
                              widget.productsBatch.quantitySeparate)) {
                        setState(() {
                          alerta =
                              "La cantidad no puede ser mayor a la cantidad restante";
                        });
                      } else {
                        setState(() {
                          alerta = "";
                        });
                      }
                    }
                  },
                  isDialog: true,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
