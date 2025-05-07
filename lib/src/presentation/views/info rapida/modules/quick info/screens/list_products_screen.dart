// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/modules/quick%20info/bloc/info_rapida_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/modules/Batchs/screens/widgets/others/dialog_loadingPorduct_widget.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ListProductsScreen extends StatefulWidget {
  const ListProductsScreen({Key? key}) : super(key: key);

  @override
  State<ListProductsScreen> createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<ListProductsScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocConsumer<InfoRapidaBloc, InfoRapidaState>(
      listener: (context, state) {
        print('state: $state');
        if (state is InfoRapidaError) {
          Navigator.pop(context);
          Get.snackbar(
            '360 Software Informa',
            'No se encontró producto, lote, paquete ni ubicación con ese código de barras',
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: Icon(Icons.error, color: Colors.red),
          );
        }

        if (state is InfoRapidaLoading) {
          showDialog(
            context: context,
            builder: (context) {
              return const DialogLoading(
                message: "Buscando informacion...",
              );
            },
          );
        }

        if (state is InfoRapidaLoaded) {
          Navigator.pop(context);
          Get.snackbar(
            '360 Software Informa',
            'Información encontrada',
            backgroundColor: white,
            colorText: primaryColorApp,
            icon: Icon(Icons.error, color: Colors.green),
          );

          if (state.infoRapidaResult.type == 'product') {
            Navigator.pushReplacementNamed(
              context,
              'product-info',
            );
          } else if (state.infoRapidaResult.type == "ubicacion") {
            Navigator.pushReplacementNamed(context, 'location-info',
                arguments: [state.infoRapidaResult]);
          }
        }
      },
      builder: (context, state) {
        final bloc = context.read<InfoRapidaBloc>();
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
                                    showCursor: true,
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
                                            bloc.add(ShowKeyboardEvent(true));
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    (bloc.productosFilters.isEmpty)
                        ? Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Text('No hay productos',
                                    style:
                                        TextStyle(fontSize: 14, color: grey)),
                                const Text(
                                    'No tiene productos en la base de datos',
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
                                itemCount: bloc.productosFilters.length,
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
                                                                  .productosFilters[
                                                                      index]
                                                                  .name ??
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
                                                        bloc.productosFilters[index].barcode ==
                                                                    false ||
                                                                bloc
                                                                        .productosFilters[
                                                                            index]
                                                                        .barcode ==
                                                                    "" ||
                                                                bloc
                                                                        .productosFilters[
                                                                            index]
                                                                        .barcode ==
                                                                    ""
                                                            ? 'Sin barcode'
                                                            : bloc
                                                                    .productosFilters[
                                                                        index]
                                                                    .barcode ??
                                                                '',
                                                        style: TextStyle(
                                                          color: bloc
                                                                          .productosFilters[
                                                                              index]
                                                                          .barcode ==
                                                                      false ||
                                                                  bloc.productosFilters[index]
                                                                          .barcode ==
                                                                      ""
                                                              ? red
                                                              : primaryColorApp,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Code: ',
                                                        style: TextStyle(
                                                          color: black,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        bloc.productosFilters[index].code ==
                                                                    false ||
                                                                bloc
                                                                        .productosFilters[
                                                                            index]
                                                                        .code ==
                                                                    "" ||
                                                                bloc
                                                                        .productosFilters[
                                                                            index]
                                                                        .code ==
                                                                    ""
                                                            ? 'Sin codigo de producto'
                                                            : bloc
                                                                    .productosFilters[
                                                                        index]
                                                                    .code ??
                                                                '',
                                                        style: TextStyle(
                                                          color: bloc
                                                                          .productosFilters[
                                                                              index]
                                                                          .code ==
                                                                      false ||
                                                                  bloc.productosFilters[index]
                                                                          .code ==
                                                                      ""
                                                              ? red
                                                              : primaryColorApp,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                bloc.productosFilters[selectedIndex!];

                            bloc.add(ShowKeyboardEvent(false));
                            FocusScope.of(context).unfocus();

                            bloc.add(GetInfoRapida(
                                selectedProduct.productId.toString(),
                                true,
                                true));
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
                    Visibility(
                      visible: bloc.isKeyboardVisible &&
                          context.read<UserBloc>().fabricante.contains("Zebra"),
                      child: CustomKeyboard(
                        isLogin: false,
                        controller: bloc.searchControllerProducts,
                        onchanged: () {
                          bloc.add(SearchProductEvent(
                            bloc.searchControllerProducts.text,
                          ));
                        },
                      ),
                    )
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
        child: BlocConsumer<InfoRapidaBloc, InfoRapidaState>(
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
                            context
                                .read<InfoRapidaBloc>()
                                .searchControllerProducts
                                .clear();
                            context
                                .read<InfoRapidaBloc>()
                                .add(ShowKeyboardEvent(false));
                            Navigator.pushReplacementNamed(
                              context,
                              'info-rapida',
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
