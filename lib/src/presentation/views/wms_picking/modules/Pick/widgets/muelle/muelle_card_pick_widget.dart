// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/widgets/others/dialog_picking_incompleted_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

class MuellePickDropdownWidget extends StatefulWidget {
  final String? selectedMuelle;
  final ProductsBatch currentProduct;
  final bool isPda;

  const MuellePickDropdownWidget({
    super.key,
    required this.selectedMuelle,
    required this.currentProduct,
    required this.isPda,
  });

  @override
  State<MuellePickDropdownWidget> createState() => _MuelleDropdownWidgetState();
}

class _MuelleDropdownWidgetState extends State<MuellePickDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    final batchBloc = context.read<PickingPickBloc>();
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
                value: batchBloc.configurations.result?.result?.muelleOption ==
                        "multiple"
                    ? batchBloc.currentProduct.barcodeLocationDest
                    : batchBloc.pickWithProducts.pick?.barcodeMuelle,
                child: Text(
                  batchBloc.configurations.result?.result?.muelleOption ==
                          "multiple"
                      ? batchBloc.currentProduct.locationDestId ?? ""
                      : batchBloc.pickWithProducts.pick?.muelle ?? "",
                  style: const TextStyle(fontSize: 14, color: black),
                ),
              ),
            ],
            onChanged: batchBloc
                        .configurations.result?.result?.manualSpringSelection ==
                    false
                ? null
                : !batchBloc.quantityIsOk &&
                        !batchBloc.locationDestIsOk &&
                        batchBloc.productIsOk
                    ? (String? newValue) {
                        print("Muelle seleccionado: $newValue");
                        if (batchBloc.configurations.result?.result
                                    ?.muelleOption ==
                                "multiple"
                            ? newValue ==
                                batchBloc.currentProduct.barcodeLocationDest
                            : newValue ==
                                batchBloc
                                    .pickWithProducts.pick?.barcodeMuelle) {
                          // Validación correcta
                          validatePicking(
                            batchBloc,
                            context,
                            widget.currentProduct,
                          );
                        } else {
                          // Si la validación falla
                          batchBloc.add(ValidateFieldsEvent(
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
              child: Text(
                batchBloc.configurations.result?.result?.muelleOption ==
                        "multiple"
                    ? batchBloc.currentProduct.locationDestId ?? ""
                    : batchBloc.pickWithProducts.pick?.muelle ?? "",
                style: const TextStyle(fontSize: 14, color: black),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Visibility(
              visible: batchBloc.configurations.result?.result?.muelleOption ==
                      "multiple"
                  ? batchBloc.currentProduct.barcodeLocationDest == false ||
                      batchBloc.currentProduct.barcodeLocationDest == null ||
                      batchBloc.currentProduct.barcodeLocationDest == ""
                  : batchBloc.pickWithProducts.pick?.barcodeMuelle == false ||
                      batchBloc.pickWithProducts.pick?.barcodeMuelle == null ||
                      batchBloc.pickWithProducts.pick?.barcodeMuelle == "",
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
    PickingPickBloc batchBloc,
    BuildContext context,
    ProductsBatch currentProduct,
  ) async {
    batchBloc.add(
        FetchPickWithProductsEvent(batchBloc.pickWithProducts.pick?.id ?? 0));

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
              child: Text("360 Software Informa",
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
                        // batchBloc.add(LoadProductEditEvent());
                        Navigator.pushReplacementNamed(
                          context,
                          'pick-detail',
                        );
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
            batchBloc.pickWithProducts.pick?.id ?? 0,
            currentProduct.idMove ?? 0));

        // batchBloc.add(EndTimePick(
        //   batchBloc.pickWithProducts.pick?.id ?? 0, DateTime.now()));

        batchBloc.add(PickingOkEvent(batchBloc.pickWithProducts.pick?.id ?? 0,
            currentProduct.idProduct ?? 0));
        batchBloc.add(FetchPickingPickFromDBEvent(false));
        batchBloc.index = 0;
        batchBloc.isSearch = true;

        Navigator.pushReplacementNamed(
          context,
          'pick',
        );
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return DialogPickIncompleted(
                currentProduct: batchBloc.currentProduct,
                cantidad: unidadesSeparadas,
                onAccepted: () {
                  Navigator.pop(context);
                  if (batchBloc
                          .configurations.result?.result?.showDetallesPicking ==
                      true) {
                    // Cerramos el foco
                    batchBloc.isSearch = false;
                    batchBloc.add(LoadProductEditEvent());

                    Navigator.pushReplacementNamed(
                      context,
                      'pick-detail',
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
