import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab2Screen extends StatelessWidget {
  const Tab2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: const FloatingActionButton(
        backgroundColor: primaryColorApp,
        onPressed: null,
        child: Icon(
          Icons.playlist_add_check_circle_sharp,
          color: Colors.white,
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        width: double.infinity,
        height: size.height * 0.8,
        // child: 
        
        // ListView.builder(
        //     itemCount: context.read<WmsPackingBloc>().listProductPacking.length,
        //     itemBuilder: (context, index) {
        //       final product =
        //           context.read<WmsPackingBloc>().listProductPacking[index];
        //       return Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 8),
        //         child: GestureDetector(
        //           onTap: () {
        //             Navigator.pushNamed(
        //               context,
        //               'Packing',
        //             );
        //           },
        //           child: Card(
        //               color: Colors.white,
        //               elevation: 5,
        //               child: Padding(
        //                 padding: const EdgeInsets.symmetric(
        //                     horizontal: 12, vertical: 10),
        //                 child: Column(
        //                   children: [
        //                     const Align(
        //                       alignment: Alignment.centerLeft,
        //                       child: Text(
        //                         "Producto:",
        //                         style: TextStyle(
        //                           fontSize: 16,
        //                           color: primaryColorApp,
        //                         ),
        //                       ),
        //                     ),
        //                     Align(
        //                         alignment: Alignment.centerLeft,
        //                         child: Text("Product: ${product.productId[1]}",
        //                             style: const TextStyle(
        //                                 fontSize: 16, color: black))),
        //                     Row(
        //                       children: [
        //                         const Text(
        //                           "Cantidad: ",
        //                           style: TextStyle(
        //                             fontSize: 16,
        //                             color: primaryColorApp,
        //                           ),
        //                         ),
        //                         Text("${product.quantity}",
        //                             style: const TextStyle(
        //                                 fontSize: 16, color: black)),
        //                         const Spacer(),
        //                         const Text(
        //                           "Unidad de medida: ",
        //                           style: TextStyle(
        //                             fontSize: 16,
        //                             color: primaryColorApp,
        //                           ),
        //                         ),
        //                         Text("${product.productUomId[1]}",
        //                             style: const TextStyle(
        //                                 fontSize: 16, color: black)),
        //                       ],
        //                     ),
        //                     if (product.lotName != false)
        //                       Row(
        //                         children: [
        //                           const Text(
        //                             "Numero de serie/lote: ",
        //                             style: TextStyle(
        //                               fontSize: 16,
        //                               color: primaryColorApp,
        //                             ),
        //                           ),
        //                           Text("${product.lotName}",
        //                               style: const TextStyle(
        //                                   fontSize: 16, color: black)),
        //                         ],
        //                       ),
        //                     if (product.expirationDate != false)
        //                       Row(
        //                         children: [
        //                           const Text(
        //                             "Fecha de caducidad: ",
        //                             style: TextStyle(
        //                               fontSize: 16,
        //                               color: primaryColorApp,
        //                             ),
        //                           ),
        //                           Text("${product.expirationDate}",
        //                               style: const TextStyle(
        //                                   fontSize: 16, color: black)),
        //                         ],
        //                       )
        //                   ],
        //                 ),
        //               )),
        //         ),
        //       );
        //     }),
      ),
    );
  }
}
