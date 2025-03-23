// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/transferencias/models/response_transferencias.dart';
import 'package:wms_app/src/presentation/views/transferencias/screens/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class MuelleDropdownWidget extends StatefulWidget {
  final String? selectedMuelle;
  final TransferenciaBloc batchBloc;
  final LineasTransferenciaTrans currentProduct;
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
                value: widget.currentProduct.locationDestName,
                child: Text(
                  widget.currentProduct.locationDestName ?? "",
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
                            widget.currentProduct.locationDestName) {
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
              child: Text(
                widget.currentProduct.locationDestName ?? "",
                style: const TextStyle(fontSize: 14, color: black),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Visibility(
              visible: widget.currentProduct.locationDestBarcode == false ||
                  widget.currentProduct.locationDestBarcode == null ||
                  widget.currentProduct.locationDestBarcode == "",
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
    TransferenciaBloc batchBloc,
    BuildContext context,
    LineasTransferenciaTrans currentProduct,
  ) async {
    // batchBloc.add(FetchBatchWithProductsEvent(
    //     batchBloc.batchWithProducts.batch?.id ?? 0));

    // Validamos que la cantidad de productos separados sea igual a la cantidad de productos pedidos

    batchBloc.add(ValidateFieldsEvent(field: "locationDest", isOk: true));
    batchBloc.add(ChangeLocationDestIsOkEvent(
        true,
        int.parse(currentProduct.productId),
        currentProduct.idTransferencia ?? 0,
        currentProduct.idMove ?? 0));
  }
  // } else {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return DialogPickingIncompleted(
  //             currentProduct: batchBloc.currentProduct,
  //             cantidad: unidadesSeparadas,
  //             batchBloc: batchBloc,
  //             onAccepted: () {
  //               Navigator.pop(context);
  //               if (batchBloc
  //                       .configurations.result?.result?.showDetallesPicking ==
  //                   true) {
  //                 // Cerramos el foco
  //                 batchBloc.isSearch = false;
  //                 batchBloc.add(LoadProductEditEvent());

  //                 Navigator.pushReplacementNamed(
  //                   context,
  //                   'batch-detail',
  //                 );
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     duration: Duration(milliseconds: 1000),
  //                     content: Text('No tienes permisos para ver detalles'),
  //                   ),
  //                 );
  //               }
  //             });
  //       });
  // }
}
