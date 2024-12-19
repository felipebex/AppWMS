import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ProductDropdownWidget extends StatelessWidget {
  final String? selectedProduct;
  final List<String> listOfProductsName;
  final String currentProductId;
  final BatchBloc batchBloc;
  final ProductsBatch currentProduct;

  final VoidCallback onAccepted;
  final bool isPDA;

  const ProductDropdownWidget({
    super.key,
    required this.selectedProduct,
    required this.listOfProductsName,
    required this.currentProductId,
    required this.batchBloc,
    required this.currentProduct,
    required this.onAccepted,
    required this.isPDA,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
            items: listOfProductsName.map((String product) {
              return DropdownMenuItem<String>(
                value: product,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: currentProductId == product
                        ? Colors.green[100]
                        : Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 45,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  child: Text(
                    product,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: black, fontSize: 14),
                  ),
                ),
              );
            }).toList(),
            onChanged: batchBloc
                        .configurations.data?.result?.manualProductSelection ==
                    false
                ? null
                : batchBloc.locationIsOk && !batchBloc.productIsOk
                    ? (String? newValue) {
                        if (newValue == currentProduct.productId.toString()) {
                          batchBloc.add(ValidateFieldsEvent(
                              field: "product", isOk: true));

                          batchBloc.add(ChangeQuantitySeparate(
                              0,
                              currentProduct.idProduct ?? 0,
                              currentProduct.idMove ?? 0));

                          batchBloc.add(ChangeProductIsOkEvent(
                              true,
                              currentProduct.idProduct ?? 0,
                              batchBloc.batchWithProducts.batch?.id ?? 0,
                              0,
                              currentProduct.idMove ?? 0));

                          batchBloc.add(ChangeIsOkQuantity(
                              true,
                              currentProduct.idProduct ?? 0,
                              batchBloc.batchWithProducts.batch?.id ?? 0,
                              currentProduct.idMove ?? 0));
                          onAccepted();
                        } else {
                          batchBloc.add(ValidateFieldsEvent(
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
          if (isPDA)
            if (currentProductId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lote/Numero de serie',
                        style: TextStyle(fontSize: 14, color: primaryColorApp),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currentProduct.lotId ?? '',
                        style: const TextStyle(fontSize: 14, color: black),
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
