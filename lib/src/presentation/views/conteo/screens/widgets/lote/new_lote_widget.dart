// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';

import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

import 'package:intl/intl.dart'; // Importamos el paquete intl

class NewLoteOrdenScreen extends StatefulWidget {
  const NewLoteOrdenScreen({super.key, this.currentProduct});

  final CountedLine? currentProduct;

  @override
  State<NewLoteOrdenScreen> createState() => _NewLoteScreenState();
}

class _NewLoteScreenState extends State<NewLoteOrdenScreen> {
  bool viewList = true;
  DateTime? selectedDate; // Para almacenar la fecha seleccionada
  int? selectedIndex; // Para almacenar el índice del lote seleccionado

  @override
  void initState() {
    super.initState();
    viewList = true;
  }

  // Función para mostrar el selector de fecha y hora

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bloc = context.read<ConteoBloc>();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: white,
        bottomNavigationBar: !viewList &&
                context.read<UserBloc>().fabricante.contains("Zebra")
            ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 35,
                ),
                child: CustomKeyboard(
                  isLogin: false,
                  controller: bloc.newLoteController,
                  onchanged: () {
                    bloc.newLoteController.text = bloc.newLoteController.text;
                  },
                ),
              )
            : null,
        body: BlocBuilder<ConteoBloc, ConteoState>(
          builder: (context, state) {
            return SizedBox(
              width: size.width * 1,
              height: size.height * 1,
              child: Column(
                children: [
                  BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
                    builder: (context, connectionStatus) {
                      return BlocConsumer<ConteoBloc, ConteoState>(
                        listener: (context, state) {
                          print('STATE ❤️‍🔥 $state');

                          if (state is CreateLoteProductSuccess) {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(
                                context, 'scan-product-conteo');
                          }

                          if (state is CreateLoteProductLoading) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const DialogLoading(
                                  message: "Creando lote espere un momento...",
                                );
                              },
                            );
                          }

                          if (state is CreateLoteProductFailure) {
                            Navigator.pop(context);
                            Get.defaultDialog(
                              title: '360 Software Informa',
                              titleStyle:
                                  TextStyle(color: Colors.red, fontSize: 18),
                              middleText: state.error,
                              middleTextStyle:
                                  TextStyle(color: black, fontSize: 14),
                              backgroundColor: Colors.white,
                              radius: 10,
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColorApp,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text('Aceptar',
                                      style: TextStyle(color: white)),
                                ),
                              ],
                            );
                          }
                        },
                        builder: (context, state) {
                          return Container(
                            decoration: BoxDecoration(
                              color: primaryColorApp,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            width: double.infinity,
                            child: Column(
                              children: [
                                const WarningWidgetCubit(),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: connectionStatus !=
                                            ConnectionStatus.online
                                        ? 0
                                        : 35,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back,
                                            color: white),
                                        onPressed: () {
                                          context.read<ConteoBloc>().add(
                                                ShowKeyboardEvent(false),
                                              );
                                          Navigator.pushReplacementNamed(
                                              context, 'scan-product-conteo');
                                        },
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: size.width * 0.2),
                                        child: const Text(
                                          'CREAR LOTE',
                                          style: TextStyle(
                                              color: white, fontSize: 18),
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  if (!bloc.isKeyboardVisible)
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: 5, top: viewList ? 0 : 10),
                      child: Text(widget.currentProduct?.productName ?? '',
                          style: TextStyle(fontSize: 12, color: black)),
                    ),

                  //184170

                  //todo barra buscar
                  Visibility(
                    visible: viewList,
                    child: SizedBox(
                        height: 55,
                        width: size.width * 1,
                        child: Padding(
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
                                    style:
                                        TextStyle(color: black, fontSize: 14),
                                    readOnly: context
                                            .read<UserBloc>()
                                            .fabricante
                                            .contains("Zebra")
                                        ? true
                                        : false,
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: bloc.searchControllerLote,
                                    showCursor: true,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: grey,
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            bloc.searchControllerLote.clear();
                                            bloc.add(SearchLotevent(
                                              '',
                                            ));
                                            bloc.add(ShowKeyboardEvent(false));
                                            FocusScope.of(context).unfocus();
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: grey,
                                            size: 20,
                                          )),
                                      disabledBorder:
                                          const OutlineInputBorder(),
                                      hintText: "Buscar lote",
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      bloc.add(SearchLotevent(
                                        value,
                                      ));
                                    },
                                    onTap: !context
                                            .read<UserBloc>()
                                            .fabricante
                                            .contains("Zebra")
                                        ? null
                                        : () {
                                            bloc.add(ShowKeyboardEvent(true));
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),

                  const SizedBox(height: 10),
                  Visibility(
                    visible: viewList,
                    child: Expanded(
                        child: ListView.builder(
                            itemCount: bloc.listLotesProductFilters.length,
                            itemBuilder: (context, index) {
                              bool isSelected = selectedIndex == index;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = isSelected ? null : index;
                                    });
                                  },
                                  child: Card(
                                    elevation: 3,
                                    color:
                                        isSelected ? Colors.green[100] : white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Lote: ${bloc.listLotesProductFilters[index].name}',
                                              style: TextStyle(
                                                  color: primaryColorApp,
                                                  fontSize: 12)),
                                          Row(
                                            children: [
                                              Text('Fecha de caducidad: ',
                                                  style: TextStyle(
                                                      color: black,
                                                      fontSize: 12)),
                                              Text(
                                                  '${bloc.listLotesProductFilters[index].expirationDate == "" || bloc.listLotesProductFilters[index].expirationDate == false ? 'Sin fecha' : bloc.listLotesProductFilters[index].expirationDate}',
                                                  style: TextStyle(
                                                      color: bloc
                                                                      .listLotesProductFilters[
                                                                          index]
                                                                      .expirationDate ==
                                                                  "" ||
                                                              bloc
                                                                      .listLotesProductFilters[
                                                                          index]
                                                                      .expirationDate ==
                                                                  false
                                                          ? red
                                                          : black,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          Visibility(
                                            visible: bloc
                                                    .listLotesProductFilters[
                                                        index]
                                                    .id ==
                                                bloc.currentProduct?.lotId,
                                            child: Text('Lote sugerido',
                                                style: TextStyle(
                                                    color: primaryColorApp,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })),
                  ),
                  Visibility(
                    visible: !viewList,
                    child: Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: bloc.newLoteController,
                              style: TextStyle(color: black, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Nombre del lote',
                                labelStyle: TextStyle(color: primaryColorApp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      bloc.newLoteController.clear();
                                      FocusScope.of(context).unfocus();
                                    },
                                    icon: const Icon(Icons.close, color: grey)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              style: TextStyle(color: black, fontSize: 14),
                              controller: bloc.dateLoteController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      bloc.dateLoteController.clear();
                                      FocusScope.of(context).unfocus();
                                    },
                                    icon: const Icon(Icons.close, color: grey)),
                                labelText: 'Fecha de caducidad',
                                labelStyle: TextStyle(color: primaryColorApp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                var pickedDate =
                                    await DatePicker.showSimpleDatePicker(
                                  titleText: 'Seleccione una fecha',
                                  context,
                                  confirmText: 'Seleccionar',
                                  cancelText: 'Cancelar',
                                  // initialDate: DateTime(2020),
                                  firstDate:
                                      //un mes atras
                                      DateTime.now()
                                          .subtract(const Duration(days: 2000)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 2000)),
                                  dateFormat: "dd-MMMM-yyyy",
                                  locale: DateTimePickerLocale.es,
                                  looping: false,
                                );

                                // Verificar si el usuario seleccionó una fecha
                                if (pickedDate != null) {
                                  // Formatear la fecha al formato "yyyy-MM-dd"
                                  final formattedDate =
                                      DateFormat('yyyy-MM-dd hh:mm')
                                          .format(pickedDate);

                                  // Actualizar el estado de la fecha seleccionada
                                  selectedDate = pickedDate;
                                  bloc.dateLoteController.text = formattedDate;
                                }
                              }, // Llamar al selector de fecha y hora
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                  Visibility(
                    visible: selectedIndex != null && viewList,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          // Aquí puedes manejar la lógica de lo que suceda cuando se seleccione el lote
                          var selectedLote =
                              bloc.listLotesProductFilters[selectedIndex!];

                          bloc.add(SelectecLoteEvent(selectedLote));

                          Navigator.pushReplacementNamed(
                            context,
                            'scan-product-conteo',
                          );

                          Get.snackbar(
                            'Lote Seleccionado',
                            'Has seleccionado el lote: ${selectedLote.name}',
                            backgroundColor: white,
                            colorText: primaryColorApp,
                            icon: Icon(Icons.check, color: Colors.green),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColorApp,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Seleccionar lote',
                          style: TextStyle(color: white),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !bloc.isKeyboardVisible,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              bloc.newLoteController.clear();
                              bloc.dateLoteController.clear();
                              setState(() {
                                viewList = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: Text(
                              'CANCELAR',
                              style: TextStyle(
                                color: white,
                              ),
                            )),
                        const SizedBox(width: 10),
                        Visibility(
                          visible: viewList,
                          child: ElevatedButton(
                              onPressed: () {
                                //ocultamos la lista de lotes
                                setState(() {
                                  viewList = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColorApp,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: Text(
                                'CREAR LOTE',
                                style: TextStyle(
                                  color: white,
                                ),
                              )),
                        ),
                        Visibility(
                          visible: !viewList,
                          child: ElevatedButton(
                              onPressed: () {
                                //ocultamos la lista de lotes
                                ///validamos que l nombre del lote no sea el mismo que ya existe en la lista
                                if (bloc.listLotesProduct
                                    .where((element) =>
                                        element.name ==
                                        bloc.newLoteController.text)
                                    .isNotEmpty) {
                                  Get.snackbar(
                                    'Error al crear lote',
                                    'El lote ya existe, por favor ingrese otro nombre',
                                    backgroundColor: white,
                                    colorText: primaryColorApp,
                                    icon:
                                        Icon(Icons.error, color: Colors.amber),
                                  );
                                  return;
                                }

                                if (bloc.newLoteController.text.isEmpty ||
                                    bloc.newLoteController.text == '' &&
                                        bloc.dateLoteController.text.isEmpty ||
                                    bloc.dateLoteController.text == "") {
                                  Get.snackbar(
                                    'Error al crear lote',
                                    'Los campos del lote no puede estar vacíos',
                                    backgroundColor: white,
                                    colorText: primaryColorApp,
                                    icon:
                                        Icon(Icons.error, color: Colors.amber),
                                  );
                                  return;
                                }

                                bloc.add(CreateLoteProduct(
                                  bloc.newLoteController.text,
                                  bloc.dateLoteController.text,
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColorApp,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: Text(
                                'AGREGAR LOTE',
                                style: TextStyle(
                                  color: white,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: bloc.isKeyboardVisible &&
                        context.read<UserBloc>().fabricante.contains("Zebra"),
                    child: CustomKeyboard(
                      isLogin: false,
                      controller: bloc.searchControllerLote,
                      onchanged: () {
                        bloc.add(SearchLotevent(
                          bloc.searchControllerLote.text,
                        ));
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
