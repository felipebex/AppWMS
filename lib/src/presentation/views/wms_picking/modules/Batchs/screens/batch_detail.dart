// ignore_for_file: unrelated_type_equality_checks

import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../utils/constans/colors.dart';

class BatchDetailScreen extends StatelessWidget {
  const BatchDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<BatchBloc, BatchState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBarGlobal(
                tittle: 'Picking Detail', actions: const SizedBox()),
            body: SizedBox(
              width: size.width,
              height: size.height * 0.85,
              child: Column(
                children: [
                  //*widget de busqueda
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller:
                              context.read<BatchBloc>().searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, color: grey),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  context
                                      .read<BatchBloc>()
                                      .add(ClearSearchProudctsBatchEvent());
                                },
                                icon: const Icon(Icons.close, color: grey)),
                            disabledBorder: const OutlineInputBorder(),
                            hintText: "Buscar productos",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            context
                                .read<BatchBloc>()
                                .add(SearchProductsBatchEvent(value));
                          },
                        ),
                      ),
                    ),
                  ),
                  // *Lista de productos
                  Expanded(
                    // height: size.height * 0.75,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: context
                              .read<BatchBloc>()
                              .batchWithProducts
                              .products!
                              .isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: context
                                  .read<BatchBloc>()
                                  .batchWithProducts
                                  .products
                                  ?.length,
                              itemBuilder: (context, index) {
                                final productsBatch = context
                                    .read<BatchBloc>()
                                    .batchWithProducts
                                    .products?[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Text(
                                                  productsBatch?.productId ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    //icono de transferir
                                                    const Icon(
                                                      Icons
                                                          .transfer_within_a_station,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("Transferir a: ",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: grey)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        productsBatch
                                                                ?.pickingId ??
                                                            '',
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                primaryColorApp)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.confirmation_number,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text(
                                                        "Numero de serie/lote: ",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: grey)),
                                                    productsBatch?.lotId ==
                                                            false
                                                        ? const Text(
                                                            "No tiene",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    primaryColorApp),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )
                                                        : Text(
                                                            productsBatch?.lotId
                                                                    ?.toString() ??
                                                                '',
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    primaryColorApp),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("Desde:",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: grey)),
                                                    Text(
                                                        productsBatch
                                                                ?.locationId
                                                                ?.toString() ??
                                                            '',
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                primaryColorApp)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.arrow_forward,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("A:",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: grey)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        productsBatch
                                                                ?.locationDestId
                                                                .toString() ??
                                                            '',
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                primaryColorApp)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.add,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("Cantidad:",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: grey)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        productsBatch?.quantity
                                                                .toString() ??
                                                            "",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                primaryColorApp)),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.add,
                                                      color: primaryColorApp,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text("is SELECTED:",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: grey)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        productsBatch?.isSelected
                                                                .toString() ??
                                                            "",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                primaryColorApp)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/empty.png',
                                      height:
                                          200), // Ajusta la altura según necesites
                                  const SizedBox(height: 10),
                                  const Text('No se encontraron resultados',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: primaryColorApp)),
                                  const Text('Intenta con otra búsqueda',
                                      style:
                                          TextStyle(fontSize: 14, color: grey)),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
