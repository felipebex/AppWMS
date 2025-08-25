import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_barcodes_widget.dart';

class ProductDropdowmnWidget extends StatelessWidget {
  const ProductDropdowmnWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  
    return Column(
      children: [
        GestureDetector(
          onTap: 
          
          (context.read<ConteoBloc>().locationIsOk &&
                  !context.read<ConteoBloc>().productIsOk &&
                  !context.read<ConteoBloc>().quantityIsOk)
              ?
              
               () {
                  Navigator.pushReplacementNamed(
                    context,
                    'search-product-conteo',
                  );
                }
              : null
              ,
          child: Card(
            color: white,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Producto',
                        style: TextStyle(fontSize: 14, color: primaryColorApp)),
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/icons/producto.png",
                    color: primaryColorApp,
                    width: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!context.read<UserBloc>().fabricante.contains("Zebra"))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.read<ConteoBloc>().currentProduct.productName ??
                    "Esperando escaneo",
                style: const TextStyle(color: black, fontSize: 14),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Image.asset(
                "assets/icons/barcode.png",
                color: primaryColorApp,
                width: 20,
              ),
              const SizedBox(width: 10),
              Text(
                context
                            .read<ConteoBloc>()
                            .currentProduct
                            .productBarcode
                            ?.isNotEmpty ??
                        false
                    ? context
                            .read<ConteoBloc>()
                            .currentProduct
                            .productBarcode ??
                        ""
                    : "Sin codigo de barras",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 12,
                    color: context
                                .read<ConteoBloc>()
                                .currentProduct
                                .productBarcode
                                ?.isNotEmpty ??
                            false
                        ? black
                        : red),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return DialogBarcodes(
                        listOfBarcodes:
                            context.read<ConteoBloc>().listOfBarcodes,
                      );
                    },
                  );
                },
                child: Visibility(
                  visible: context.read<ConteoBloc>().listOfBarcodes.isNotEmpty,
                  child: Image.asset("assets/icons/package_barcode.png",
                      color: primaryColorApp, width: 20),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text('codigo: ', style: TextStyle(fontSize: 14, color: black)),
              Text(
                context
                            .read<ConteoBloc>()
                            .currentProduct
                            .productCode
                            ?.isNotEmpty ??
                        true
                    ? context.read<ConteoBloc>().currentProduct.productCode ??
                        "Sin codigo "
                    : "Sin codigo ",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 12,
                    color: context
                                .read<ConteoBloc>()
                                .currentProduct
                                .productCode
                                ?.isNotEmpty ??
                            false
                        ? primaryColorApp
                        : red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
