import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/views/devoluciones/models/product_devolucion_model.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/bloc/devoluciones_bloc.dart';
import 'package:wms_app/src/presentation/views/devoluciones/screens/widgets/buildBarcodeInputField_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_numbers_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class DialogEditProduct extends StatelessWidget {
  const DialogEditProduct({
    super.key,
    required this.functionValidate,
    required this.focusNode,
    required this.focusNodeQuantityManual,
    required this.controller,
    required this.isEdit,
  });

  final dynamic Function(String) functionValidate;
  final FocusNode focusNode;
  final FocusNode focusNodeQuantityManual;
  final TextEditingController controller;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    TextEditingController controllerManualQuantity = TextEditingController();

    final size = MediaQuery.sizeOf(context);
    final bloc = context.read<DevolucionesBloc>();
    return WillPopScope(
      onWillPop: () async {
        // Evita que el diálogo se cierre al presionar el botón de retroceso
        return false;
      },
      child: BlocBuilder<DevolucionesBloc, DevolucionesState>(
        builder: (context, state) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              actionsAlignment: MainAxisAlignment.spaceBetween,
              contentPadding: const EdgeInsets.all(5),
              title: Center(
                  child: Text('Producto encontrado',
                      style: TextStyle(
                        color: primaryColorApp,
                        fontSize: 18,
                      ))),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del diálogo
                children: [
                  BuildBarcodeInputField(
                      devolucionesBloc: context.read<DevolucionesBloc>(),
                      focusNode: focusNode,
                      functionValidate: (value) {
                        return functionValidate(value);
                      },
                      controller: controller,
                      functionUpdate: (keyLabel) {
                        context
                            .read<DevolucionesBloc>()
                            .add(UpdateScannedValueEvent(keyLabel, 'quantity'));
                      }),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icono o imagen del producto
                          // Puedes usar Image.network(product.imageUrl) si tienes URLs de imagen
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bloc.currentProduct.name ?? "",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Barcode: ',
                                      style: TextStyle(
                                          fontSize: 12, color: primaryColorApp),
                                    ),
                                    Text(
                                      '${bloc.currentProduct.barcode}',
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Código: ',
                                      style: TextStyle(
                                          fontSize: 12, color: primaryColorApp),
                                    ),
                                    Text(
                                      '${bloc.currentProduct.code}',
                                      style: const TextStyle(
                                          fontSize: 12, color: black),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Cantidad: ',
                                style: TextStyle(
                                    fontSize: 12, color: primaryColorApp),
                              ),
                              Text(
                                '${bloc.quantitySelected}',
                                style:
                                    const TextStyle(fontSize: 12, color: black),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  bloc.add(
                                      ShowQuantityEvent(!bloc.viewQuantity));
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: primaryColorApp,
                                  size: 20,
                                  semanticLabel: 'Añadir cantidad',
                                ),
                              ),
                            ],
                          ),
                          if (bloc.viewQuantity) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 35,
                              child: TextFormField(
                                focusNode: focusNodeQuantityManual,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'))
                                ],
                                controller: controllerManualQuantity,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                style:
                                    const TextStyle(fontSize: 12, color: black),
                                onChanged: (value) {
                                  // Actualiza la cantidad seleccionada
                                  if (value.isNotEmpty) {
                                    try {
                                      bloc.quantitySelected =
                                          double.parse(value);
                                    } catch (e) {
                                      print(
                                          '❌ Error al convertir a número: $e');
                                    }
                                  } else {
                                    bloc.quantitySelected = 0;
                                  }
                                },
                                // onFieldSubmitted: onManualQuantitySubmitted,
                                decoration:
                                    InputDecorations.authInputDecoration(
                                  hintText: 'Cantidad',
                                  labelText: 'Cantidad',
                                  suffixIconButton: IconButton(
                                    onPressed: () {
                                      bloc.add(ShowQuantityEvent(false));
                                      controllerManualQuantity.clear();
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                      color: grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            CustomKeyboardNumber(
                              isDialog: true,
                              controller: controllerManualQuantity,
                              onchanged: () {
                                // Actualiza la cantidad seleccionada
                                if (controllerManualQuantity.text.isNotEmpty) {
                                  try {
                                    bloc.quantitySelected = double.parse(
                                        controllerManualQuantity.text);
                                  } catch (e) {
                                    print('❌ Error al convertir a número: $e');
                                  }
                                } else {
                                  bloc.quantitySelected = 0;
                                }
                              },
                            ),
                            if (!isEdit)
                              ElevatedButton(
                                onPressed: () {
                                  print(
                                      'Cantidad seleccionada: ${bloc.quantitySelected}');

                                  if (bloc.currentProduct.tracking == 'lot') {
                                    if (bloc.lotesProductCurrent.id == null) {
                                      Get.snackbar(
                                        '360 Software Informa',
                                        'El producto no tiene lote asignado',
                                        backgroundColor: white,
                                        colorText: primaryColorApp,
                                        icon: const Icon(Icons.error,
                                            color: Colors.red),
                                      );
                                      return;
                                    } else {
                                      bloc.add(Addproduct(
                                        ProductDevolucion(
                                          productId:
                                              bloc.currentProduct.productId,
                                          name: bloc.currentProduct.name,
                                          code: bloc.currentProduct.code,
                                          barcode: bloc.currentProduct.barcode,
                                          quantity: bloc.quantitySelected,
                                          lotId: bloc.lotesProductCurrent.id,
                                          lotName:
                                              bloc.lotesProductCurrent.name,
                                          uom: bloc.currentProduct.uom,
                                          tracking:
                                              bloc.currentProduct.tracking,
                                          category:
                                              bloc.currentProduct.category,
                                          expirationTime: bloc
                                              .currentProduct.expirationTime,
                                          useExpirationDate: bloc
                                              .currentProduct.useExpirationDate,
                                          expirationDate: bloc
                                              .currentProduct.expirationDate,
                                          weight: bloc.currentProduct.weight,
                                          weightUomName:
                                              bloc.currentProduct.weightUomName,
                                          volume: bloc.currentProduct.volume,
                                          volumeUomName:
                                              bloc.currentProduct.volumeUomName,
                                          locationId:
                                              bloc.currentProduct.locationId,
                                          locationName:
                                              bloc.currentProduct.locationName,
                                        ),
                                      ));
                                      Navigator.pop(context);
                                      return;
                                    }
                                  } else {
                                    bloc.add(Addproduct(
                                      ProductDevolucion(
                                        productId:
                                            bloc.currentProduct.productId,
                                        name: bloc.currentProduct.name,
                                        code: bloc.currentProduct.code,
                                        barcode: bloc.currentProduct.barcode,
                                        quantity: bloc.quantitySelected,
                                        lotId: 0,
                                        lotName: "",
                                        uom: bloc.currentProduct.uom,
                                        tracking: bloc.currentProduct.tracking,
                                        category: bloc.currentProduct.category,
                                        expirationTime:
                                            bloc.currentProduct.expirationTime,
                                        useExpirationDate: bloc
                                            .currentProduct.useExpirationDate,
                                        expirationDate:
                                            bloc.currentProduct.expirationDate,
                                        weight: bloc.currentProduct.weight,
                                        weightUomName:
                                            bloc.currentProduct.weightUomName,
                                        volume: bloc.currentProduct.volume,
                                        volumeUomName:
                                            bloc.currentProduct.volumeUomName,
                                        locationId:
                                            bloc.currentProduct.locationId,
                                        locationName:
                                            bloc.currentProduct.locationName,
                                      ),
                                    ));
                                    Navigator.pop(context);
                                    return;
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColorApp,
                                  minimumSize: Size(size.width * 0.93, 30),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('APLICAR CANTIDAD',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ),
                            if (isEdit)
                              ElevatedButton(
                                onPressed: () {
                                  print(
                                      'Cantidad seleccionada: ${bloc.quantitySelected}');

                                  if (bloc.currentProduct.tracking == 'lot') {
                                    if (bloc.lotesProductCurrent.id == null) {
                                      Get.snackbar(
                                        '360 Software Informa',
                                        'El producto no tiene lote asignado',
                                        backgroundColor: white,
                                        colorText: primaryColorApp,
                                        icon: const Icon(Icons.error,
                                            color: Colors.red),
                                      );
                                      return;
                                    } else {
                                      bloc.add(UpdateProductInfoEvent());
                                      Navigator.pop(context);
                                      return;
                                    }
                                  } else {
                                    bloc.add(UpdateProductInfoEvent());
                                    Navigator.pop(context);
                                    return;
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColorApp,
                                  minimumSize: Size(size.width * 0.93, 30),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('EDITAR CANTIDAD',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14)),
                              ),
                          ]
                        ],
                      ),
                    ),
                  ),
                  if (!bloc.viewQuantity &&
                      bloc.currentProduct.tracking == 'lot') ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Text(
                              'Lote: ',
                              style: TextStyle(
                                  fontSize: 12, color: primaryColorApp),
                            ),
                            Text(
                              'Sin lote',
                              style: const TextStyle(fontSize: 12, color: red),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: primaryColorApp,
                                size: 20,
                                semanticLabel: 'Añadir cantidad',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ]
                ],
              ),
              actions: [
                if (!bloc.viewQuantity) ...[
                  ElevatedButton(
                    onPressed: () {
                      bloc.add(ClearScannedValueEvent('product'));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.white)),
                  ),
                  if (!isEdit)
                    ElevatedButton(
                      onPressed: () {
                        if (bloc.currentProduct.tracking == 'lot') {
                          if (bloc.lotesProductCurrent.id == null) {
                            Get.snackbar(
                              '360 Software Informa',
                              'El producto no tiene lote asignado',
                              backgroundColor: white,
                              colorText: primaryColorApp,
                              icon: const Icon(Icons.error, color: Colors.red),
                            );
                            return;
                          } else {
                            bloc.add(Addproduct(
                              ProductDevolucion(
                                productId: bloc.currentProduct.productId,
                                name: bloc.currentProduct.name,
                                code: bloc.currentProduct.code,
                                barcode: bloc.currentProduct.barcode,
                                quantity: bloc.quantitySelected,
                                lotId: bloc.lotesProductCurrent.id,
                                lotName: bloc.lotesProductCurrent.name,
                                uom: bloc.currentProduct.uom,
                                tracking: bloc.currentProduct.tracking,
                                category: bloc.currentProduct.category,
                                expirationTime:
                                    bloc.currentProduct.expirationTime,
                                useExpirationDate:
                                    bloc.currentProduct.useExpirationDate,
                                expirationDate:
                                    bloc.currentProduct.expirationDate,
                                weight: bloc.currentProduct.weight,
                                weightUomName:
                                    bloc.currentProduct.weightUomName,
                                volume: bloc.currentProduct.volume,
                                volumeUomName:
                                    bloc.currentProduct.volumeUomName,
                                locationId: bloc.currentProduct.locationId,
                                locationName: bloc.currentProduct.locationName,
                              ),
                            ));
                            Navigator.pop(context);
                            return;
                          }
                        } else {
                          bloc.add(Addproduct(
                            ProductDevolucion(
                              productId: bloc.currentProduct.productId,
                              name: bloc.currentProduct.name,
                              code: bloc.currentProduct.code,
                              barcode: bloc.currentProduct.barcode,
                              quantity: bloc.quantitySelected,
                              lotId: 0,
                              lotName: "",
                              uom: bloc.currentProduct.uom,
                              tracking: bloc.currentProduct.tracking,
                              category: bloc.currentProduct.category,
                              expirationTime:
                                  bloc.currentProduct.expirationTime,
                              useExpirationDate:
                                  bloc.currentProduct.useExpirationDate,
                              expirationDate:
                                  bloc.currentProduct.expirationDate,
                              weight: bloc.currentProduct.weight,
                              weightUomName: bloc.currentProduct.weightUomName,
                              volume: bloc.currentProduct.volume,
                              volumeUomName: bloc.currentProduct.volumeUomName,
                              locationId: bloc.currentProduct.locationId,
                              locationName: bloc.currentProduct.locationName,
                            ),
                          ));
                          Navigator.pop(context);
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColorApp,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Agregar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  if (isEdit)
                    ElevatedButton(
                      onPressed: () {
                        if (bloc.currentProduct.tracking == 'lot') {
                          if (bloc.lotesProductCurrent.id == null) {
                            Get.snackbar(
                              '360 Software Informa',
                              'El producto no tiene lote asignado',
                              backgroundColor: white,
                              colorText: primaryColorApp,
                              icon: const Icon(Icons.error, color: Colors.red),
                            );
                            return;
                          } else {
                            bloc.add(UpdateProductInfoEvent());
                            Navigator.pop(context);
                            return;
                          }
                        } else {
                          bloc.add(UpdateProductInfoEvent());
                          Navigator.pop(context);
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColorApp,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Editar',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
