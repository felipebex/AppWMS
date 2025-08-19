import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Pick/bloc/picking_pick_bloc.dart';

class LocationDropdownWidget extends StatelessWidget {
  final String? selectedLocation;
  final List<String> positionsOrigen;
  final String currentLocationId;
  final ProductsBatch currentProduct;
  final bool isPDA;


  const LocationDropdownWidget({
    super.key,
    required this.selectedLocation,
    required this.positionsOrigen,
    required this.currentLocationId,
    required this.currentProduct,
    required this.isPDA,
  });

  @override
  Widget build(BuildContext context) {
    final batchBloc = context.read<PickingPickBloc>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // DropdownButton
          DropdownButton<String>(
            underline: Container(height: 0),
            borderRadius: BorderRadius.circular(10),
            focusColor: Colors.white,
            isExpanded: true,
            hint: Text(
              'Ubicación de origen',
              style: TextStyle(
                fontSize: 14,
                color: primaryColorApp,
              ),
            ),
            icon: Image.asset(
              "assets/icons/ubicacion.png",
              color: primaryColorApp,
              width: 20,
            ),
            value: selectedLocation,
            items: positionsOrigen.map((String location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: currentLocationId == location
                        ? Colors.green[100]
                        : Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 45,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: black, fontSize: 14),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: batchBloc
                        .configurations.result?.result?.locationPickingManual ==
                    false
                ? null
                : batchBloc.locationIsOk
                    ? null
                    : (String? newValue) {
                        if (newValue == currentProduct.locationId.toString()) {
                          batchBloc.add(ValidateFieldsEvent(
                              field: "location", isOk: true));
                          batchBloc.add(ChangeLocationIsOkEvent(
                              currentProduct.idProduct ?? 0,
                              batchBloc.pickWithProducts.pick?.id ?? 0,
                              currentProduct.idMove ?? 0));

                          batchBloc.oldLocation =
                              currentProduct.locationId.toString();
                        } else {
                          batchBloc.add(ValidateFieldsEvent(
                              field: "location", isOk: false));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(milliseconds: 1000),
                            content: const Text('Ubicacion erronea'),
                            backgroundColor: Colors.red[200],
                          ));
                        }
                      },
          ),

          Visibility(
            visible: currentProduct.barcodeLocation == false ||
                currentProduct.barcodeLocation == null ||
                currentProduct.barcodeLocation == "",
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sin codigo de barras",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14, color: red),
              ),
            ),
          ),

          // Mostrar ubicación actual

          Visibility(
            visible: isPDA,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    currentLocationId,
                    style: const TextStyle(fontSize: 14, color: black),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
