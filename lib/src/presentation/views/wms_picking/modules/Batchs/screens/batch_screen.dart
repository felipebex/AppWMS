// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/products_batch_model.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/blocs/batch_bloc/batch_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/appBarInfo_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/dropdowbutton_widget.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/progressIndicatos_widget.dart';
import 'package:wms_app/src/presentation/widgets/appbar.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/theme/input_decoration.dart';

class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  _BatchDetailScreenState createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchScreen> {
  String scannedValue1 = '';
  String scannedValue2 = '';
  String scannedValue3 = '';

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();

  String? selectedLocation;

  bool viewQuantity = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.read<BatchBloc>().locationIsOk) {
      FocusScope.of(context).requestFocus(focusNode1);
    } else {
      FocusScope.of(context).requestFocus(focusNode2);
    }
  }

  @override
  void dispose() {
    focusNode4.dispose(); // Limpiar el FocusNode
    super.dispose();
  }

  TextEditingController cantidadController = TextEditingController();
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocBuilder<BatchBloc, BatchState>(builder: (context, state) {
        int completedTasks = context.read<BatchBloc>().index;
        int totalTasks =
            context.read<BatchBloc>().batchWithProducts.products?.length ?? 0;
        double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
        final batchBloc = context.read<BatchBloc>();

        final currentProduct =
            batchBloc.batchWithProducts.products?[batchBloc.index];

        batchBloc.add(GetProductById(currentProduct?.idProduct ?? 0));

        if (state is LoadProductsBatchSuccesStateBD ||
            state is ChangeIsOkState ||
            state is CurrentProductChangedState ||
            state is SelectNovedadState ||
            state is QuantityChangedState) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 30),
                  width: size.width,
                  height: 120,
                  color: primaryColorApp,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          quantity = 0;
                          context.read<BatchBloc>().completedProducts = 0;
                        },
                        child: AppBarInfo(
                            currentProduct: currentProduct ?? ProductsBatch()),
                      ),
                      ProgressIndicatorWidget(
                        progress: progress ?? 0,
                        completed: completedTasks,
                        total: totalTasks,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Form(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            //todo : ubicacion de origen
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: batchBloc.locationIsOk
                                          ? green
                                          : yellow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Card(
                                  color: batchBloc.locationIsOk
                                      ? Colors.green[100]
                                      : Colors.grey[300],
                                  elevation: 5,
                                  child: Container(
                                    width: size.width * 0.85,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Focus(
                                      focusNode: focusNode1,
                                      onKey:
                                          (FocusNode node, RawKeyEvent event) {
                                        if (event is RawKeyDownEvent) {
                                          if (event.logicalKey ==
                                              LogicalKeyboardKey.enter) {
                                            if (scannedValue1.isNotEmpty) {
                                              print(
                                                  "ScannedValue1: $scannedValue1");
                                              //todo? aca es donde validamos la entrada con la ubicacion del producto
                                              if (scannedValue1.toLowerCase() ==
                                                  currentProduct?.locationId
                                                      .toLowerCase()) {
                                                batchBloc.add(
                                                    ChangeLocationIsOkEvent(
                                                        true));
                                                batchBloc.oldLocation =
                                                    currentProduct?.locationId;
                                                Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode2);
                                                });
                                              } else {
                                                setState(() {
                                                  scannedValue1 =
                                                      ""; //limpiamos el valor escaneado
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  content: const Text(
                                                      'Codigo erroneo'),
                                                  backgroundColor:
                                                      Colors.red[200],
                                                ));
                                              }
                                            }

                                            return KeyEventResult.handled;
                                          } else {
                                            setState(() {
                                              scannedValue1 +=
                                                  event.data.keyLabel;
                                            });
                                            return KeyEventResult.handled;
                                          }
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: DropdownButton<String>(
                                                underline: Container(
                                                  height: 0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                focusColor: Colors.white,
                                                isExpanded: true,
                                                hint: const Text(
                                                  'Ubicación de origen',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: primaryColorApp),
                                                ),
                                                icon: Image.asset(
                                                  "assets/icons/ubicacion.png",
                                                  color: primaryColorApp,
                                                  width: 24,
                                                ),
                                                value: selectedLocation,
                                                items: batchBloc.positions
                                                    .map((String location) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: location,
                                                    child: Text(location),
                                                  );
                                                }).toList(),
                                                onChanged: batchBloc
                                                        .locationIsOk
                                                    ? null
                                                    : (String? newValue) {
                                                        if (newValue ==
                                                            currentProduct
                                                                ?.locationId) {
                                                          batchBloc.add(
                                                              ChangeLocationIsOkEvent(
                                                                  true));
                                                          batchBloc
                                                                  .oldLocation =
                                                              currentProduct
                                                                  ?.locationId;
                                                          Future.delayed(
                                                              const Duration(
                                                                  seconds: 1),
                                                              () {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    focusNode2);
                                                          });

                                                          // Aquí puedes usar un FocusNode si es necesario
                                                          // FocusScope.of(context).requestFocus(focusNode2);
                                                        } else {
                                                          print(
                                                              "Ubicacion incorrecta");
                                                        }
                                                      },
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    currentProduct
                                                            ?.locationId ??
                                                        '',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // todo: Producto

                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: batchBloc.productIsOk
                                          ? green
                                          : yellow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Card(
                                  color: batchBloc.productIsOk
                                      ? Colors.green[100]
                                      : Colors.grey[300],
                                  elevation: 5,
                                  child: Container(
                                    width: size.width * 0.85,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Focus(
                                      focusNode: focusNode2,
                                      onKey:
                                          (FocusNode node, RawKeyEvent event) {
                                        if (event is RawKeyDownEvent) {
                                          if (event.logicalKey ==
                                              LogicalKeyboardKey.enter) {
                                            if (scannedValue2.isNotEmpty) {
                                              if (scannedValue2.toLowerCase() ==
                                                  batchBloc.product.barcode
                                                      ?.toLowerCase()) {
                                                quantity = quantity + 1;
                                                batchBloc.add(
                                                    ChangeProductIsOkEvent(
                                                        true));
                                                batchBloc.add(
                                                    ChangeIsOkQuantity(true));
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 100), () {
                                                  FocusScope.of(context)
                                                      .requestFocus(focusNode3);
                                                });
                                              } else {
                                                setState(() {
                                                  scannedValue2 =
                                                      ""; //limpiamos el valor escaneado
                                                });
                                                //mostramos alerta de error
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  duration: const Duration(
                                                      milliseconds: 1000),
                                                  content: const Text(
                                                      'Codigo erroneo'),
                                                  backgroundColor:
                                                      Colors.red[200],
                                                ));
                                              }
                                            }

                                            return KeyEventResult.handled;
                                          } else {
                                            setState(() {
                                              scannedValue2 +=
                                                  event.data.keyLabel;
                                            });
                                            return KeyEventResult.handled;
                                          }
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: DropdownButton<String>(
                                                underline: Container(
                                                  height: 0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                focusColor: Colors.white,
                                                isExpanded: true,
                                                hint: const Text(
                                                  'Producto',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: primaryColorApp),
                                                ),
                                                icon: Image.asset(
                                                  "assets/icons/producto.png",
                                                  color: primaryColorApp,
                                                  width: 24,
                                                ),
                                                value: selectedLocation,
                                                // items: batchBloc.positions
                                                items: batchBloc
                                                    .batchWithProducts.products
                                                    ?.map((ProductsBatch
                                                        product) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: product.productId
                                                        .toString(),
                                                    child: Text(product
                                                        .productId
                                                        .toString()),
                                                  );
                                                }).toList(),

                                                onChanged: !batchBloc
                                                        .locationIsOk
                                                    ? null
                                                    : (String? newValue) {
                                                        if (newValue ==
                                                            currentProduct
                                                                ?.productId) {
                                                          quantity =
                                                              quantity + 1;
                                                          batchBloc.add(
                                                              ChangeProductIsOkEvent(
                                                                  true));
                                                          batchBloc.add(
                                                              ChangeIsOkQuantity(
                                                                  true));
                                                          Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      100), () {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    focusNode3);
                                                          });
                                                        } else {}
                                                      },
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                currentProduct?.productId
                                                        .toString() ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 16, color: black),
                                              ),
                                            ),

                                            const SizedBox(height: 10),
                                            //informacion del lote:
                                            if (batchBloc.product.tracking ==
                                                    'lot' ||
                                                batchBloc.product.tracking ==
                                                    'serial')
                                              const Column(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Lote/Numero de serie ',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              primaryColorApp),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: black),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //todo: cantidad
                SizedBox(
                  width: size.width,
                  height: viewQuantity ? 210 : 150,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Card(
                          color:
                              batchBloc.quantityIsOk ? white : Colors.grey[300],
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Center(
                              child: Row(
                                children: [
                                  const Text('Recoger:',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      currentProduct?.quantity?.toString() ??
                                          "",
                                      style: const TextStyle(
                                          color: primaryColorApp, fontSize: 18),
                                    ),
                                  ),
                                  const Text('UND',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18)),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Expanded(
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: Focus(
                                            focusNode: focusNode3,
                                            onKey: (FocusNode node,
                                                RawKeyEvent event) {
                                              if (event is RawKeyDownEvent) {
                                                if (event.logicalKey ==
                                                    LogicalKeyboardKey.enter) {
                                                  if (scannedValue3
                                                      .isNotEmpty) {
                                                    print(
                                                        "ScannedValue3: $scannedValue3");
                                                    //todo? aca es donde validamos la entrada con la ubicacion del producto
                                                    if (scannedValue3
                                                            .toLowerCase() ==
                                                        batchBloc
                                                            .product.barcode
                                                            ?.toLowerCase()) {
                                                      setState(() {
                                                        quantity = quantity + 1;
                                                        scannedValue3 =
                                                            ""; //limpiamos el valor escaneado
                                                      });
                                                      //validamos que la cantidad sea igual a la cantidad del producto
                                                      if (quantity ==
                                                          currentProduct
                                                              ?.quantity) {
                                                        _nextProduct(
                                                            currentProduct!,
                                                            batchBloc);
                                                      }
                                                    } else {
                                                      setState(() {
                                                        scannedValue3 =
                                                            ""; //limpiamos el valor escaneado
                                                      });
                                                      //mostramos alerta de error
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1000),
                                                        content: const Text(
                                                            'Codigo erroneo'),
                                                        backgroundColor:
                                                            Colors.red[200],
                                                      ));
                                                    }
                                                  }

                                                  return KeyEventResult.handled;
                                                } else {
                                                  setState(() {
                                                    scannedValue3 +=
                                                        event.data.keyLabel;
                                                  });
                                                  return KeyEventResult.handled;
                                                }
                                              }
                                              return KeyEventResult.ignored;
                                            },
                                            child: Text(quantity.toString(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18)),
                                          )),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: batchBloc.quantityIsOk &&
                                              quantity > 0
                                          ? () {
                                              setState(() {
                                                viewQuantity = !viewQuantity;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.edit_note_rounded,
                                          color: primaryColorApp, size: 30)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: viewQuantity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: TextFormField(
                            focusNode: focusNode4,
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Solo permite dígitos
                            ],
                            controller: cantidadController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecorations.authInputDecoration(
                              hintText: 'Cantidad',
                              labelText: 'Cantidad',
                            ),
                            //al dar enter
                            onFieldSubmitted: (value) {
                              setState(() {
                                //validamos que el texto no este vacio
                                if (value.isNotEmpty) {
                                  if (int.parse(value) >
                                      currentProduct?.quantity) {
                                    cantidadController.clear();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content:
                                          const Text('Cantidad incorrecta'),
                                      backgroundColor: Colors.red[200],
                                    ));
                                  } else {
                                    if (int.parse(value) ==
                                        currentProduct?.quantity) {
                                      _nextProduct(currentProduct!, batchBloc);
                                    } else {
                                      quantity = int.parse(value);
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return DialogAdvetenciaCantidadScreen(
                                                currentProduct: currentProduct!,
                                                cantidad: quantity,
                                                onAccepted: () {
                                                  _nextProduct(currentProduct,
                                                      batchBloc);
                                                });
                                          });
                                    }
                                  }
                                }
                                viewQuantity = false;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ElevatedButton(
                            onPressed: batchBloc.quantityIsOk && quantity >= 0
                                ? () {
                                    int cantidad = int.parse(
                                        cantidadController.text.isEmpty
                                            ? quantity.toString()
                                            : cantidadController.text);
                                    if (cantidad == currentProduct!.quantity) {
                                      _nextProduct(currentProduct, batchBloc);
                                    } else {
                                      if (cantidad < currentProduct.quantity) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return DialogAdvetenciaCantidadScreen(
                                                  currentProduct:
                                                      currentProduct,
                                                  cantidad: cantidad,
                                                  onAccepted: () {
                                                    _nextProduct(currentProduct,
                                                        batchBloc);
                                                  });
                                            });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          content:
                                              const Text('Cantidad erronea'),
                                          backgroundColor: Colors.red[200],
                                        ));
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColorApp,
                              minimumSize: Size(size.width * 0.93, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'APLICAR CANTIDAD',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )),
                    ],
                  ),
                ),
                // YourWidget(),
              ],
            ),
          );
        }

        if (state is EmptyroductsBatch) {
          return Scaffold(
            appBar:
                AppBarGlobal(tittle: 'Detalle de Batch', actions: Container()),
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/empty.png',
                      height: 150), // Ajusta la altura según necesites
                  const SizedBox(height: 10),
                  const Text('No se encontraron resultados',
                      style: TextStyle(fontSize: 18, color: grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                          'El Batch  ${context.read<BatchBloc>().batchWithProducts.batch?.name} no tiene productos',
                          style: const TextStyle(
                              fontSize: 18, color: primaryColorApp),
                          textAlign: TextAlign.center),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 200,
                  child: Image.asset(
                    "assets/images/icon.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Error al cargar los datos...",
                  style: TextStyle(fontSize: 18, color: black),
                ),
                const Text(
                  "Comprueba tu conexión a internet",
                  style: TextStyle(fontSize: 16, color: black),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(size.width * 0.6, 40),
                    ),
                    child: const Text(
                      "Atras",
                      style: TextStyle(color: white, fontSize: 16),
                    ))
              ],
            ),
          ),
        );
      }),
    );
  }

  void _nextProduct(ProductsBatch currentProduct, BatchBloc batchBloc) {
    //reinciiamos la cantidad contada de cada producto
    setState(() {
      quantity = 0;
    });
    cantidadController.clear();

    ///cambiamos al siguiente producto
    context
        .read<BatchBloc>()
        .add(ChangeCurrentProduct(currentProduct: currentProduct));

    //mostramos un modal de cargando que dure 2 segudnos y luego redirigimos a la pantalla de resumen
    showDialog(
        context: context,
        builder: (context) {
          return const DialogLoading();
        });
    // Esperar 1 segundos y cerrar el diálogo y redirigirel focus
    Future.delayed(const Duration(seconds: 1), () {
      if (currentProduct.locationId != batchBloc.oldLocation) {
        FocusScope.of(context).requestFocus(focusNode1);
      } else {
        FocusScope.of(context).requestFocus(focusNode2);
      }
      Navigator.of(context).pop();
    });
  }
}
