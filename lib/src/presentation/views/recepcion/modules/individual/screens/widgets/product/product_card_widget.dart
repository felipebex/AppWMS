import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/models/recepcion_response_model.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ProductDropdownOrderWidget extends StatelessWidget {
  final String? selectedProduct;
  final List<LineasTransferencia> listOfProductsName;
  final String currentProductId;
  final LineasTransferencia currentProduct;

  final bool isPDA;

  const ProductDropdownOrderWidget({
    super.key,
    required this.selectedProduct,
    required this.listOfProductsName,
    required this.currentProductId,
    required this.currentProduct,
    required this.isPDA,
  });

  @override
  Widget build(BuildContext context) {
    final recepcionBloc = context.read<RecepcionBloc>();
    return SizedBox(
      height: 48,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DropdownButton for Product selection
            DropdownButton<String>(
              underline: Container(height: 0),
              borderRadius: BorderRadius.circular(10),
              focusColor: Colors.white,
              isExpanded: true,
              hint: Text(
                'Producto',
                style: TextStyle(fontSize: 14, color: primaryColorApp),
              ),
              icon: Image.asset(
                "assets/icons/producto.png",
                color: primaryColorApp,
                width: 20,
              ),
              value: selectedProduct,
              items: listOfProductsName.map((LineasTransferencia product) {
                return DropdownMenuItem<String>(
                  value: product.productName.toString(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: currentProduct.idMove == product.idMove
                          ? Colors.green[100]
                          : Colors.white,
                    ),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      product.productName.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: black,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: recepcionBloc.configurations.result?.result
                          ?.manualProductReading ==
                      false
                  ? null
                  : !recepcionBloc.productIsOk
                      ? (String? newValue) {
                          if (newValue ==
                              currentProduct.productName.toString()) {
                            recepcionBloc.add(ValidateFieldsOrderEvent(
                                field: "product", isOk: true));

                            recepcionBloc.add(ChangeQuantitySeparate(
                              0,
                              int.parse(currentProduct.productId),
                              currentProduct.idRecepcion ?? 0,
                              currentProduct.idMove ?? 0,
                            ));

                            recepcionBloc.add(ChangeProductIsOkEvent(
                                currentProduct.idRecepcion ?? 0,
                                true,
                                int.parse(currentProduct.productId),
                                0,
                                currentProduct.idMove ?? 0));

                            if (recepcionBloc.configurations.result?.result
                                    ?.scanDestinationLocationReception ==
                                false) {
                              recepcionBloc.add(ChangeIsOkQuantity(
                                currentProduct.idRecepcion ?? 0,
                                true,
                                int.parse(currentProduct.productId),
                                currentProduct.idMove ?? 0,
                              ));
                            }
                          } else {
                            recepcionBloc.add(ValidateFieldsOrderEvent(
                                field: "product", isOk: false));

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: const Duration(milliseconds: 1000),
                              content: const Text('Producto erroneo'),
                              backgroundColor: Colors.red[200],
                            ));
                          }
                        }
                      : null,
            ),

            // Información del producto

            if (isPDA)
              Align(
                alignment: Alignment.centerLeft,
                child: Visibility(
                  visible: currentProductId.isEmpty,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Sin código de barras",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ),
                ),
              ),

            // Lote/Numero de serie
            // if (isPDA)
            //   if (currentProductId.isNotEmpty)
            //     Padding(
            //       padding: const EdgeInsets.only(bottom: 10),
            //       child: Column(
            //         children: [
            //           Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text(
            //               'Lote/Numero de serie',
            //               style:
            //                   TextStyle(fontSize: 14, color: primaryColorApp),
            //             ),
            //           ),
            //           Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text(
            //               currentProduct.lotId ?? '',
            //               style: const TextStyle(fontSize: 14, color: black),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
          ],
        ),
      ),
    );
  }
}
