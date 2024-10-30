// ignore_for_file: unrelated_type_equality_checks

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/widgets/appbar.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class WmsPackingScreen extends StatefulWidget {
  const WmsPackingScreen({super.key});

  @override
  State<WmsPackingScreen> createState() => _WmsPackingScreenState();
}

class _WmsPackingScreenState extends State<WmsPackingScreen> {
  NotchBottomBarController controller = NotchBottomBarController();

  @override
  void initState() {
    controller.index = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar:
            AppBarGlobal(tittle: 'BATCH - PACKING', actions: const SizedBox()),
        body: Container(
          margin: const EdgeInsets.only(top: 10),
          width: size.width * 1,
          height: size.height * 0.9,
          child:

              ///*listado de bacths

              BlocConsumer<WMSPickingBloc, PickingState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Column(
                children: [
                  //*barra de buscar

                  SizedBox(
                      height: 60,
                      width: size.width * 1,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: size.width * 0.9,
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 3,
                                    child: TextFormField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      controller: context
                                          .read<WMSPickingBloc>()
                                          .searchController,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.search,
                                            color: grey),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              context
                                                  .read<WMSPickingBloc>()
                                                  .searchController
                                                  .clear();
                                              context
                                                  .read<WMSPickingBloc>()
                                                  .add(SearchBatchEvent(''));
                                              FocusScope.of(context).unfocus();
                                            },
                                            icon: const Icon(Icons.close,
                                                color: grey)),
                                        disabledBorder:
                                            const OutlineInputBorder(),
                                        hintText: "Buscar batch",
                                        hintStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        context
                                            .read<WMSPickingBloc>()
                                            .add(SearchBatchEvent(value));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),

                  //*listado de batchs
                  Expanded(
                    child: context
                            .read<WMSPickingBloc>()
                            .filteredBatchs
                            .isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: context
                                .read<WMSPickingBloc>()
                                .filteredBatchs
                                .length,
                            itemBuilder: (context, index) {
                              final List<BatchsModel> inProgressBatches =
                                  context
                                      .read<WMSPickingBloc>()
                                      .filteredBatchs
                                      .where((element) =>
                                          element.state == 'in_progress')
                                      .toList(); // Convertir a lista

                              // Asegurarse de que hay batches en progreso
                              if (inProgressBatches.isEmpty) {
                                return const Center(
                                    child: Text('No hay batches en progreso.'));
                              }

                              // Comprobar que el índice no está fuera de rango
                              if (index >= inProgressBatches.length) {
                                return const SizedBox(); // O manejar de otra forma
                              }

                              final batch = inProgressBatches[
                                  index]; // Acceder al batch filtrado

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: GestureDetector(
                                  onTap: () async {
                                    context.read<WmsPackingBloc>().add(
                                        FetchBatchWithProductsEvent(
                                            batch.id ?? 0));

                                    context.read<WmsPackingBloc>().add(
                                        LoadAllPackingEvent(batch.id ?? 0, context));
                                    Navigator.pushNamed(context, 'packing-list',
                                        arguments: batch);
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 5,
                                    child: ListTile(
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: primaryColorApp,
                                      ),
                                      leading: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),

                                            //sombras
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 2))
                                            ]),
                                        child: Image.asset(
                                          "assets/icons/producto.png",
                                          color: batch.state == 'done'
                                              ? Colors.green
                                              : batch.state == 'cancel'
                                                  ? Colors.red
                                                  : primaryColorApp,
                                          width: 24,
                                        ),
                                      ),
                                      title: Text(batch.name ?? '',
                                          style: const TextStyle(fontSize: 14)),
                                      subtitle: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text("Tipo de operación:",
                                                style: TextStyle(
                                                    fontSize: 14, color: grey)),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              batch.pickingTypeId.toString(),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: primaryColorApp),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Builder(
                                              builder: (context) {
                                                // Verifica si `scheduledDate` es false o null
                                                String displayDate;
                                                if (batch.scheduledDate ==
                                                        false ||
                                                    batch.scheduledDate ==
                                                        null) {
                                                  displayDate = 'sin fecha';
                                                } else {
                                                  try {
                                                    DateTime dateTime =
                                                        DateTime.parse(batch
                                                            .scheduledDate!);
                                                    // Formatear la fecha usando Intl
                                                    displayDate = DateFormat(
                                                            'dd MMMM yyyy',
                                                            'es_ES')
                                                        .format(dateTime);
                                                  } catch (e) {
                                                    displayDate =
                                                        'sin fecha'; // Si ocurre un error al parsear
                                                  }
                                                }

                                                return Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_month_sharp,
                                                      color: primaryColorApp,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      displayDate,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          Builder(builder: (context) {
                                            dynamic nameUser = batch.userId;

                                            if (batch.userId is List) {
                                              nameUser = batch.userId[1] ??
                                                  'Sin responsable';
                                            }
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    color: primaryColorApp,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    nameUser == false
                                                        ? 'Sin responsable'
                                                        : nameUser.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: black),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                        150), // Ajusta la altura según necesites
                                const SizedBox(height: 10),
                                const Text('No se encontraron resultados',
                                    style:
                                        TextStyle(fontSize: 18, color: grey)),
                                const Text('Intenta con otra búsqueda',
                                    style:
                                        TextStyle(fontSize: 14, color: grey)),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
