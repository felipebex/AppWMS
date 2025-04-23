// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/bloc/inventario_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({Key? key}) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocBuilder<InventarioBloc, InventarioState>(
      builder: (context, state) {
        final bloc = context.read<InventarioBloc>();
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
                                    controller: bloc.searchControllerLocation,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: grey,
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            bloc.searchControllerLocation
                                                .clear();
                                            bloc.add(SearchLocationEvent(
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
                                      hintText: "Buscar ubicación",
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      bloc.add(SearchLocationEvent(
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
                    Expanded(
                        child: ListView.builder(
                            itemCount: bloc.ubicacionesFilters.length,
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
                                        child: SizedBox(
                                          // height: 30,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Nombre: ',
                                                    style: TextStyle(
                                                      color: black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    bloc
                                                            .ubicacionesFilters[
                                                                index]
                                                            .name ??
                                                        '',
                                                    style: TextStyle(
                                                      color: primaryColorApp,
                                                      fontSize: 12,
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
                                                                .ubicacionesFilters[
                                                                    index]
                                                                .barcode ==
                                                            false
                                                        ? 'Sin barcode'
                                                        : bloc
                                                                .ubicacionesFilters[
                                                                    index]
                                                                .barcode ??
                                                            '',
                                                    style: TextStyle(
                                                      color: bloc
                                                                  .ubicacionesFilters[
                                                                      index]
                                                                  .barcode ==
                                                              false
                                                          ? red
                                                          : primaryColorApp,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
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

                            
                            // seleccionamos la ubicacion
                            final selectedLocation =
                                bloc.ubicacionesFilters[selectedIndex!];

                            //seleccionamos la ubicacion
                            bloc.add(ValidateFieldsEvent(
                                field: "location", isOk: true));
                            bloc.add(ChangeLocationIsOkEvent(selectedLocation));

                            bloc.add(ShowKeyboardEvent(false));
                            FocusScope.of(context).unfocus();

                            setState(() {
                              selectedIndex == null;
                            });

                            Navigator.pushReplacementNamed(
                              context,
                              'inventario',
                              arguments: selectedLocation,
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
                    Visibility(
                      visible: bloc.isKeyboardVisible &&
                          context.read<UserBloc>().fabricante.contains("Zebra"),
                      child: CustomKeyboard(
                        isLogin: false,
                        controller: bloc.searchControllerLocation,
                        onchanged: () {
                          bloc.add(SearchLocationEvent(
                            bloc.searchControllerLocation.text,
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
        child: BlocConsumer<InventarioBloc, InventarioState>(
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
                                .read<InventarioBloc>()
                                .add(ShowKeyboardEvent(false));
                            Navigator.pushReplacementNamed(
                              context,
                              'inventario',
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: size.width * 0.2),
                          child: Text('UBICACIONES',
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
