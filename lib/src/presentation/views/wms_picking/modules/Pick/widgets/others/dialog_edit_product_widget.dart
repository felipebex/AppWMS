// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/models/novedades_response_model.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';

import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class DialogEditProductPickWidget extends StatefulWidget {
  final ProductsBatch productsBatch;

  const DialogEditProductPickWidget({
    super.key,
    required this.productsBatch,
  });

  @override
  State<DialogEditProductPickWidget> createState() =>
      _DialogEditProductWidgetState();
}

class _DialogEditProductWidgetState extends State<DialogEditProductPickWidget> {
  String alerta = "";
  String? selectedNovedad; // Variable para almacenar la opción seleccionada
  double tolerance = 0.000001; // o un valor adecuado para tu caso
  @override
  void initState() {
    context.read<PickingPickBloc>().add(LoadAllNovedadesPickEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PickingPickBloc>();
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: Center(
        child: Text(
            "Editar Cantidad del Producto\n${widget.productsBatch.productId}",
            textAlign: TextAlign.center,
            style: TextStyle(color: primaryColorApp, fontSize: 13)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.add, color: primaryColorApp, size: 20),
                const SizedBox(width: 5),
                const Text("Unidades:",
                    style: TextStyle(fontSize: 13, color: black)),
                const SizedBox(width: 5),
                Text(widget.productsBatch.quantity.toString(),
                    style: const TextStyle(fontSize: 13, color: green)),
              ],
            ),
            Row(
              children: [
                Icon(Icons.check, color: primaryColorApp, size: 20),
                const SizedBox(width: 5),
                const Text("Separadas:",
                    style: TextStyle(fontSize: 13, color: black)),
                const SizedBox(width: 5),
                Text(
                    widget.productsBatch.quantitySeparate == null
                        ? "0"
                        : widget.productsBatch.quantitySeparate
                            .toStringAsFixed(2),
                    style: const TextStyle(fontSize: 13, color: Colors.amber)),
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
                          style: TextStyle(fontSize: 13, color: black)),
                      TextSpan(
                          text:
                              "${(widget.productsBatch.quantity - (widget.productsBatch.quantitySeparate ?? 0)).toStringAsFixed(2)} ",
                          style: TextStyle(
                              fontSize: 13,
                              color: primaryColorApp,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 35,
                    child: TextFormField(
                      autofocus: true,
                      showCursor: true,
                      controller: bloc.editProductController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      decoration: InputDecorations.authInputDecoration(
                        hintText: 'Cantidad',
                        labelText: 'Cantidad',
                        suffixIconButton: IconButton(
                          onPressed: () {
                            bloc.editProductController.clear();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: primaryColorApp,
                            size: 20,
                          ),
                        ),
                      ),
                      onChanged:
                          context.read<UserBloc>().fabricante.contains("Zebra")
                              ? null
                              : (value) {
                                  bloc.editProductController.text = value;

                                  if (value.isNotEmpty) {
                                    double? cantidad = double.tryParse(value);
                                    if (cantidad == null) {
                                      bloc.editProductController.clear();
                                      setState(() {
                                        alerta =
                                            "Por favor ingresa un número válido.";
                                      });
                                    } else if (cantidad == 0.0) {
                                      bloc.editProductController.clear();
                                      setState(() {
                                        alerta = "La cantidad no puede ser 0";
                                      });
                                    } else if (cantidad >
                                        (widget.productsBatch.quantity -
                                            (widget.productsBatch
                                                    .quantitySeparate ??
                                                0))) {
                                      bloc.editProductController.clear();
                                      setState(() {
                                        alerta =
                                            "La cantidad no puede ser mayor a la cantidad restantee";
                                      });
                                    } else {
                                      setState(() {
                                        alerta = "";
                                      });
                                    }
                                  }
                                },
                    ),
                  ),
                  const SizedBox(height: 5),
                  Visibility(
                    visible:
                        int.tryParse(bloc.editProductController.text) != null &&
                            double.parse(bloc.editProductController.text) == 0,
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<String>(
                          underline: Container(height: 0),
                          selectedItemBuilder: (BuildContext context) {
                            return bloc.novedades.map<Widget>((Novedad item) {
                              return Text(item.name ?? '');
                            }).toList();
                          },
                          borderRadius: BorderRadius.circular(10),
                          focusColor: Colors.white,
                          isExpanded: true,
                          isDense: true,
                          hint: const Text(
                            'Seleccionar novedad',
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    black), // Cambia primaryColorApp a tu color
                          ),
                          icon: Image.asset(
                            "assets/icons/novedad.png",
                            color: primaryColorApp,
                            width: 24,
                          ),
                          value:
                              selectedNovedad, // Muestra la opción seleccionada
                          alignment: Alignment.centerLeft,
                          style: const TextStyle(
                              color: black,
                              fontSize:
                                  14), // Cambia primaryColorApp a tu color
                          items: bloc.novedades.map((Novedad item) {
                            return DropdownMenuItem<String>(
                              value: item.name,
                              child: Text(item.name ?? ''),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedNovedad =
                                  newValue; // Actualiza el estado con la nueva selección
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(alerta,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: bloc.editProductController.text.isEmpty
                          ? null
                          : () async {
                              double cantidad = double.parse(
                                  bloc.editProductController.text.isEmpty
                                      ? "0"
                                      : bloc.editProductController.text);

                              if (cantidad == 0 && selectedNovedad == null) {
                                setState(() {
                                  alerta = "Debe seleccionar una novedad";
                                });
                                return;
                              } else if (cantidad >
                                  (widget.productsBatch.quantity ?? 0) -
                                      (widget.productsBatch.quantitySeparate ??
                                          0)) {
                                setState(() {
                                  alerta =
                                      "La cantidad no puede ser mayor a la cantidad restante";
                                });
                                return;
                              } else {
                                final dynamic cantidadReuqest =
                                    ((widget.productsBatch.quantitySeparate ??
                                            0) +
                                        cantidad);
                                if (selectedNovedad != null && cantidad == 0) {
                                  DataBaseSqlite db = DataBaseSqlite();
                                  await db.updateNovedad(
                                      widget.productsBatch.batchId ?? 0,
                                      widget.productsBatch.idProduct ?? 0,
                                      selectedNovedad ?? '',
                                      widget.productsBatch.idMove ?? 0);
                                }
                                //actualizar la cantidad separada en la bd
                                bloc.add(ChangeQuantitySeparate(
                                    cantidadReuqest,
                                    widget.productsBatch.idProduct ?? 0,
                                    widget.productsBatch.idMove ?? 0));

                                bloc.add(SendProductEditOdooEvent(
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
                      child: BlocBuilder<PickingPickBloc, PickingPickState>(
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
                  Visibility(
                    visible:
                        context.read<UserBloc>().fabricante.contains("Zebra"),
                    child: CustomKeyboardNumber(
                      controller: bloc.editProductController,
                      onchanged: () {
                        final value = bloc.editProductController.text;
                        if (value.isNotEmpty) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) {
                            double cantidad = parsed;
                            if (cantidad -
                                    (widget.productsBatch.quantity -
                                        (widget.productsBatch
                                                .quantitySeparate ??
                                            0)) >
                                tolerance) {
                              setState(() {
                                alerta =
                                    "La cantidad no puede ser mayor a la cantidad restante";
                              });
                            } else {
                              setState(() {
                                alerta = "";
                              });
                            }
                          } else {
                            setState(() {
                              alerta = "Por favor ingresa un número válido.";
                            });
                          }
                        }
                      },
                      isDialog: true,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
