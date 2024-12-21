import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_picking_incompleted_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';

class MuelleDropdownWidget extends StatefulWidget {
  final String? selectedMuelle;
  final BatchBloc batchBloc;
  final ProductsBatch currentProduct;
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
            items: widget.batchBloc.muelles.map((String muelle) {
              return DropdownMenuItem<String>(
                value: muelle,
                child: Text(
                  muelle,
                  style: const TextStyle(color: black, fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: widget.batchBloc
                        .configurations.data?.result?.manualSpringSelection ==
                    false
                ? null
                : !widget.batchBloc.quantityIsOk &&
                        !widget.batchBloc.locationDestIsOk &&
                        widget.batchBloc.productIsOk
                    ? (String? newValue) {
                        if (newValue ==
                            widget.batchBloc.batchWithProducts.batch?.muelle) {
                          // Validación correcta
                          validatePicking(widget.batchBloc, context, widget.currentProduct, );
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
                widget.batchBloc.batchWithProducts.batch?.muelle.toString() ?? '',
                style: const TextStyle(fontSize: 14, color: black),
              ),
            ),
          ),
        ],
      ),
    );
  }

void validatePicking(
    BatchBloc batchBloc, BuildContext context, ProductsBatch currentProduct, ) {
  
  batchBloc.add(FetchBatchWithProductsEvent(
      batchBloc.batchWithProducts.batch?.id ?? 0));

  // Validamos que la cantidad de productos separados sea igual a la cantidad de productos pedidos
  final double unidadesSeparadas =
      double.parse(batchBloc.calcularUnidadesSeparadas());
  
  if (unidadesSeparadas == "100.0" || unidadesSeparadas == 100.0) {
    batchBloc.add(ValidateFieldsEvent(field: "locationDest", isOk: true));
    batchBloc.add(ChangeLocationDestIsOkEvent(
        true,
        currentProduct.idProduct ?? 0,
        batchBloc.batchWithProducts.batch?.id ?? 0,
        currentProduct.idMove ?? 0));

    batchBloc.add(PickingOkEvent(batchBloc.batchWithProducts.batch?.id ?? 0,
        currentProduct.idProduct ?? 0));
    context.read<WMSPickingBloc>().add(LoadBatchsFromDBEvent());
    context.read<BatchBloc>().index = 0;
    context.read<BatchBloc>().isSearch = true;

    Navigator.pop(context);
  } else {
    showDialog(
        context: context,
        builder: (context) {
          return DialogPickingIncompleted(
              currentProduct: batchBloc.currentProduct,
              cantidad: unidadesSeparadas,
              batchBloc: batchBloc,
              onAccepted: () {
                Navigator.pop(context);
                if (batchBloc
                        .configurations.data?.result?.showDetallesPicking ==
                    true) {
                  // Cerramos el foco
                  batchBloc.isSearch = false;
                  batchBloc.add(LoadProductEditEvent());
                  
                  // Comprobamos si el widget aún está montado antes de hacer setState
                  if (mounted) {
                   
                     batchBloc.add(IsShouldRunDependencies(false));
                  }

                  Navigator.pushNamed(
                    context,
                    'batch-detail',
                  ).then((_) {
                    // Solo volvemos a cambiar el estado si el widget sigue montado
                    if (mounted) {
                      batchBloc.add(IsShouldRunDependencies(true));
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 1000),
                      content: const Text('No tienes permisos para ver detalles'),
                      backgroundColor: Colors.red[200],
                    ),
                  );
                }
              });
        });
  }
}

}
