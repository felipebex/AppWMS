// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';

import 'package:wms_app/src/presentation/views/transferencias/transfer-externa/bloc/transfer_externa_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class SearchProductScreenTrans extends StatefulWidget {
  const SearchProductScreenTrans({Key? key}) : super(key: key);

  @override
  State<SearchProductScreenTrans> createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreenTrans> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocBuilder<TransferExternaBloc, TransferExternaState>(
      builder: (context, state) {
        final bloc = context.read<TransferExternaBloc>();
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            backgroundColor: white,
            body: SizedBox(
                width: size.width * 1,
                height: size.height * 1,
                child: Column(
                  children: [
                    _AppBarInfo(size: size),
                    SizedBox(
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
                                    readOnly: context
                                            .read<UserBloc>()
                                            .fabricante
                                            .contains("Zebra")
                                        ? true
                                        : false,
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: bloc.searchControllerProducts,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: grey,
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            bloc.searchControllerProducts
                                                .clear();
                                            bloc.add(SearchProductEvent(
                                              '',
                                            ));
                                            bloc.add(ShowKeyboardTransExtEvent(false));
                                            FocusScope.of(context).unfocus();
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: grey,
                                            size: 20,
                                          )),
                                      disabledBorder:
                                          const OutlineInputBorder(),
                                      hintText: "Buscar producto",
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      bloc.add(SearchProductEvent(
                                        value,
                                      ));
                                    },
                                    onTap: !context
                                            .read<UserBloc>()
                                            .fabricante
                                            .contains("Zebra")
                                        ? null
                                        : () {
                                            bloc.add(ShowKeyboardTransExtEvent(true));
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    (bloc.productosUbicacionFilters.isEmpty)
                        ? Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Text('No hay productos',
                                    style:
                                        TextStyle(fontSize: 14, color: grey)),
                                const Text('Intente buscar con otra ubicacion',
                                    style:
                                        TextStyle(fontSize: 12, color: grey)),
                                Visibility(
                                  visible: context
                                      .read<UserBloc>()
                                      .fabricante
                                      .contains("Zebra"),
                                  child: Container(
                                    height: 60,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                                itemCount:
                                    bloc.productosUbicacionFilters.length,
                                itemBuilder: (context, index) {
                                  bool isSelected = selectedIndex == index;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex =
                                              isSelected ? null : index;
                                        });
                                      },
                                      child: Card(
                                        elevation: 3,
                                        color: isSelected
                                            ? Colors.green[100]
                                            : white,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: SizedBox(
                                              // height: 30,
                                              child: Column(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Nombre: ',
                                                          style: TextStyle(
                                                            color: black,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          bloc
                                                                  .productosUbicacionFilters[
                                                                      index]
                                                                  .productName ??
                                                              '',
                                                          style: TextStyle(
                                                            color:
                                                                primaryColorApp,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Barcode: ',
                                                        style: TextStyle(
                                                          color: black,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        bloc
                                                                    .productosUbicacionFilters[
                                                                        index]
                                                                    .barcode ==
                                                                false
                                                            ? 'Sin barcode'
                                                            : bloc
                                                                    .productosUbicacionFilters[
                                                                        index]
                                                                    .barcode ??
                                                                '',
                                                        style: TextStyle(
                                                          color: bloc
                                                                      .productosUbicacionFilters[
                                                                          index]
                                                                      .barcode ==
                                                                  false
                                                              ? red
                                                              : primaryColorApp,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible: bloc
                                                            .productosUbicacionFilters[
                                                                index]
                                                            .productTracking ==
                                                        'lot',
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'lote: ',
                                                          style: TextStyle(
                                                            color: black,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          bloc
                                                                      .productosUbicacionFilters[
                                                                          index]
                                                                      .lotName ==
                                                                  false
                                                              ? 'Sin barcode'
                                                              : bloc
                                                                      .productosUbicacionFilters[
                                                                          index]
                                                                      .lotName ??
                                                                  '',
                                                          style: TextStyle(
                                                            color: bloc
                                                                        .productosUbicacionFilters[
                                                                            index]
                                                                        .lotName ==
                                                                    false
                                                                ? red
                                                                : primaryColorApp,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                      ),
                                    ),
                                  );
                                })),
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: selectedIndex != null,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedIndex != null) {
                            final selectedProduct =
                                bloc.productosUbicacionFilters[selectedIndex!];

                            bloc.add(ShowKeyboardTransExtEvent(false));
                            FocusScope.of(context).unfocus();

                            //seleccionamos el producto

                            bloc.add(ValidateFieldsEvent(
                                field: "product", isOk: true));
                            bloc.add(ChangeProductIsOkEvent(selectedProduct));

                            bloc.add(ChangeIsOkQuantity(true));

                            setState(() {
                              selectedIndex == null;
                            });

                            Navigator.pushReplacementNamed(
                              context,
                              'inventario',
                            );

                            Get.snackbar(
                              'Producto Seleccionado',
                              'Has seleccionado el producto: ${selectedProduct.productName}',
                              backgroundColor: white,
                              colorText: primaryColorApp,
                              icon: Icon(Icons.check, color: Colors.green),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColorApp,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(size.width * 0.9, 40),
                        ),
                        child: Text("Seleccionar",
                            style: TextStyle(
                              color: white,
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          ),
        );
      },
    );
  }
}

class _AppBarInfo extends StatelessWidget {
  const _AppBarInfo({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: primaryColorApp,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      width: double.infinity,
      child: BlocProvider(
        create: (context) => ConnectionStatusCubit(),
        child: BlocConsumer<TransferExternaBloc, TransferExternaState>(
            listener: (context, state) {},
            builder: (context, status) {
              return Column(
                children: [
                  const WarningWidgetCubit(),
                  Padding(
                    padding: EdgeInsets.only(
                        top: status != ConnectionStatus.online ? 0 : 35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: white),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              'inventario',
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: size.width * 0.22),
                          child: Text('PRODUCTOS',
                              style: TextStyle(color: white, fontSize: 18)),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
