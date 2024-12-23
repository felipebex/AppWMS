import 'package:flutter/material.dart';
import 'package:wms_app/src/presentation/views/wms_packing/domain/lista_product_packing.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ProductDropdownPackingWidget extends StatelessWidget {
  final String? selectedProduct;
  final List<PorductoPedido> listOfProductsName;
  final String currentProductId;
  final WmsPackingBloc batchBloc;
  final PorductoPedido currentProduct;

  final bool isPDA;

  const ProductDropdownPackingWidget({
    super.key,
    required this.selectedProduct,
    required this.listOfProductsName,
    required this.currentProductId,
    required this.batchBloc,
    required this.currentProduct,
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
            items: 
            listOfProductsName.map((PorductoPedido product) {
              return DropdownMenuItem<String>(
                value: product.productId.toString(),
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
                    product.idProduct.toString(),
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

            
            onChanged: 
            
            // batchBloc
            //             .configurations.data?.result?.manualProductSelection ==
            //         false
            //     ? null
                // : 
                batchBloc.locationIsOk && !batchBloc.productIsOk
                    ? (String? newValue) {
                        if (newValue == currentProduct.productId.toString()) {
                          batchBloc.add(ValidateFieldsPackingEvent(
                              field: "product", isOk: true));

                          batchBloc.add(ChangeQuantitySeparate(
                              0,
                              currentProduct.productId ?? 0,
                              currentProduct.pedidoId ?? 0,
                              currentProduct.idMove ?? 0));

                          batchBloc.add(ChangeProductIsOkEvent(
                              true,
                              currentProduct.productId ?? 0,
                              currentProduct.pedidoId ?? 0,
                              0,
                              currentProduct.idMove ?? 0));

                          batchBloc.add(ChangeIsOkQuantity(
                              true,
                              currentProduct.productId ?? 0,
                             currentProduct.pedidoId ?? 0,
                              currentProduct.idMove ?? 0));
                        } else {

                          batchBloc.add(ValidateFieldsPackingEvent(
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
