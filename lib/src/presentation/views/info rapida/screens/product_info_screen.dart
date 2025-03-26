import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/connection_status_cubit.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/info%20rapida/screens/widgets/info_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ProductInfoScreen extends StatelessWidget {
  const ProductInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: white,
      body: Container(
        width: size.width * 1,
        height: size.height * 1,
        child: Column(
          children: [
            AppBar(size: size),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Producto",
                  style: TextStyle(
                      color: black, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: size.width * 1,
                child: Card(
                  elevation: 3,
                  color: white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Bio Varsol Fraga AgradSoft & Magicx500ml",
                            style: TextStyle(
                                color: black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ProductInfoRow(
                          title: 'Precio: ',
                          value: '1.000',
                        ),
                        ProductInfoRow(
                          title: 'Disponible: ',
                          value: '764 UND',
                        ),
                        ProductInfoRow(
                          title: 'Previsto: ',
                          value: '1264 UND',
                        ),
                        ProductInfoRow(
                          title: 'Peso: ',
                          value: '0.4',
                        ),
                        ProductInfoRow(
                          title:
                              'Volumen: ', // Este parece repetido, si es correcto, déjalo así
                          value: '0.0m3',
                        ),
                        ProductInfoRow(
                          title:
                              'Categoria del Producto: ', // Este parece repetido, si es correcto, déjalo así
                          value: 'Limpiador PVC Palc',
                        ),

                        //listado de ubicaciones
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ubicaciones",
                  style: TextStyle(
                      color: black, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            //listado de ubicaciones
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    color: white,
                    child: ListTile(
                      title: Text(
                        'SM/Packing Zone/ $index',
                        style: TextStyle(
                            color: primaryColorApp,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        children: [
                          ProductInfoRow(
                            title:
                                'Cantidad: ', // Este parece repetido, si es correcto, déjalo así
                            value: '60.0',
                          ),
                          ProductInfoRow(
                            title:
                                'CANT Reservada: ', // Este parece repetido, si es correcto, déjalo así
                            value: '60.0',
                          ),
                          ProductInfoRow(
                            title:
                                'Lote: ', // Este parece repetido, si es correcto, déjalo así
                            value: '60.0',
                          ),
                          ProductInfoRow(
                            title:
                                'Fecha de entrada: ', // Este parece repetido, si es correcto, déjalo así
                            value: '29-03-2023 08:22:54',
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: (){

                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: size.width * 0.4,
                                child: Card(
                                  color: white,
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.compare_arrows_sharp,
                                          color: primaryColorApp,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 5),
                                        Text('TRANSFERIR',
                                            style: TextStyle(
                                                color: primaryColorApp,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )),
            const SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}

class AppBar extends StatelessWidget {
  const AppBar({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: BlocBuilder<ConnectionStatusCubit, ConnectionStatus>(
            builder: (context, status) {
          return Column(
            children: [
              const WarningWidgetCubit(),
              Padding(
                padding: EdgeInsets.only(
                    bottom: 10,
                    top: status != ConnectionStatus.online ? 0 : 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: white),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          'info-rapida',
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.1),
                      child: const Text("INFORMACIÓN RÁPIDA",
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
