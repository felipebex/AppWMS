// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/db/database.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_picking_incompleted_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

class MuelleDropdownWidget extends StatefulWidget {
  final String? selectedMuelle;
  final BatchBloc batchBloc;
  final ProductsBatch currentProduct;
  final bool isPda;

  const MuelleDropdownWidget({
    super.key,
    required this.selectedMuelle,
    required this.batchBloc,
    required this.currentProduct,
    required this.isPda,
  });

  @override
  State<MuelleDropdownWidget> createState() => _MuelleDropdownWidgetState();
}

class _MuelleDropdownWidgetState extends State<MuelleDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // DropdownButton para seleccionar el Muelle
          DropdownButton<String>(
            underline: Container(height: 0),
            borderRadius: BorderRadius.circular(10),
            focusColor: Colors.white,
            isExpanded: true,
            hint: Text(
              'Ubicación de destino',
              style: TextStyle(
                fontSize: 14,
                color: primaryColorApp,
              ),
            ),
            icon: Image.asset(
              "assets/icons/packing.png",
              color: primaryColorApp,
              width: 20,
            ),
            value: widget.selectedMuelle,
            items: [
              DropdownMenuItem(
                value: widget.batchBloc.currentProduct.barcodeLocationDest,
                child: Text(
                  widget.batchBloc.currentProduct.locationDestId ?? "",
                  style: const TextStyle(fontSize: 14, color: black),
                ),
              ),
            ],
            onChanged: widget.batchBloc.configurations.result?.result
                        ?.manualSpringSelection ==
                    false
                ? null
                : !widget.batchBloc.quantityIsOk &&
                        !widget.batchBloc.locationDestIsOk &&
                        widget.batchBloc.productIsOk
                    ? (String? newValue) {
                        print("Muelle seleccionado: $newValue");
                        if (newValue ==
                            widget
                                .batchBloc.currentProduct.barcodeLocationDest) {
                          // Validación correcta
                          validatePicking(
                            widget.batchBloc,
                            context,
                            widget.currentProduct,
                          );
                        } else {
                          // Si la validación falla
                          widget.batchBloc.add(ValidateFieldsEvent(
                              field: "locationDest", isOk: false));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(milliseconds: 1000),
                            content: const Text('Muelle erróneo'),
                            backgroundColor: Colors.red[200],
                          ));
                        }
                      }
                    : null,
          ),

          Visibility(
            visible: widget.isPda,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    widget.batchBloc.currentProduct.locationDestId ?? "",
                    style: const TextStyle(fontSize: 14, color: black),
                  ),
                  // const Text("/"),
                  // Text(
                  //   widget.batchBloc.batchWithProducts.batch?.muelle ?? "",
                  //   style: TextStyle(fontSize: 14, color: primaryColorApp),
                  // )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Visibility(
              visible: widget.batchBloc.currentProduct.barcodeLocationDest ==
                      false ||
                  widget.batchBloc.currentProduct.barcodeLocationDest == null ||
                  widget.batchBloc.currentProduct.barcodeLocationDest == "",
              child: const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Sin código de barras",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 13, color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void validatePicking(
    BatchBloc batchBloc,
    BuildContext context,
    ProductsBatch currentProduct,
  ) async {
    batchBloc.add(FetchBatchWithProductsEvent(
        batchBloc.batchWithProducts.batch?.id ?? 0));

    // Validamos que la cantidad de productos separados sea igual a la cantidad de productos pedidos
    final double unidadesSeparadas =
        double.parse(batchBloc.calcularUnidadesSeparadas());

    if (unidadesSeparadas == "100.0" || unidadesSeparadas >= 100.0) {
      var productsToSend = batchBloc.filteredProducts
          .where((element) => element.isSendOdoo == 0)
          .toList();

      // Si hay productos pendientes de enviar a Odoo, mostramos un modal
      if (productsToSend.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Center(
              child: Text("Advertencia",
                  style: TextStyle(color: yellow, fontSize: 16)),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Tienes productos que no han sido enviados al wms. revisa la lista de productos y envíalos antes de continuar.",
                    style: TextStyle(color: black, fontSize: 14)),
                const SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (batchBloc.configurations.result?.result
                              ?.showDetallesPicking ==
                          true) {
                        //cerramos el focus
                        batchBloc.isSearch = false;
                        batchBloc.add(LoadProductEditEvent());
                        // batchBloc.add(IsShouldRunDependencies(false));
                        Navigator.pushReplacementNamed(
                          context,
                          'batch-detail',
                        ).then((_) {
                          // batchBloc.add(IsShouldRunDependencies(true));
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 1000),
                            content:
                                Text('No tienes permisos para ver detalles'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: Text('Ver productos',
                        style: TextStyle(color: primaryColorApp, fontSize: 12)))
              ],
            ),
          ),
        );
      } else {
        batchBloc.add(ValidateFieldsEvent(field: "locationDest", isOk: true));
        batchBloc.add(ChangeLocationDestIsOkEvent(
            true,
            currentProduct.idProduct ?? 0,
            batchBloc.batchWithProducts.batch?.id ?? 0,
            currentProduct.idMove ?? 0));

        batchBloc.add(PickingOkEvent(batchBloc.batchWithProducts.batch?.id ?? 0,
            currentProduct.idProduct ?? 0));
        context.read<WMSPickingBloc>().add(FilterBatchesBStatusEvent(
              '',
            ));
        context.read<BatchBloc>().index = 0;
        context.read<BatchBloc>().isSearch = true;

        Navigator.pushReplacementNamed(context, 'wms-picking', arguments: 0);
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return DialogPickingIncompleted(
                currentProduct: batchBloc.currentProduct,
                cantidad: unidadesSeparadas,
                batchBloc: batchBloc,
                onAccepted: () {
                  Navigator.pop(context);
                  if (batchBloc
                          .configurations.result?.result?.showDetallesPicking ==
                      true) {
                    // Cerramos el foco
                    batchBloc.isSearch = false;
                    batchBloc.add(LoadProductEditEvent());

                    // Comprobamos si el widget aún está montado antes de hacer setState
                    if (mounted) {
                      // batchBloc.add(IsShouldRunDependencies(false));
                    }

                    Navigator.pushReplacementNamed(
                      context,
                      'batch-detail',
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(milliseconds: 1000),
                        content: Text('No tienes permisos para ver detalles'),
                      ),
                    );
                  }
                });
          });
    }
  }
}
