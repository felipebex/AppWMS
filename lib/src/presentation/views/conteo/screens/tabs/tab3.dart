// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/conteo/models/conteo_response_model.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/bloc/conteo_bloc.dart';
import 'package:wms_app/src/presentation/views/conteo/screens/widgets/others/products_empty_widget.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class Tab3ScreenConteo extends StatefulWidget {
  const Tab3ScreenConteo({
    super.key,
    required this.ordenConteo,
  });

  final DatumConteo? ordenConteo;

  @override
  State<Tab3ScreenConteo> createState() => _Tab3ScreenRecepState();
}

class _Tab3ScreenRecepState extends State<Tab3ScreenConteo> {
  Map<String, List<CountedLine>> _groupByLocation(List<CountedLine> productos) {
    final map = <String, List<CountedLine>>{};
    for (final producto in productos) {
      final location = producto.locationName ?? 'Sin ubicación';
      map.putIfAbsent(location, () => []).add(producto);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<ConteoBloc, ConteoState>(
        listener: (context, state) {},
        builder: (context, state) {
          final conteoBloc = context.read<ConteoBloc>();
          final productosContados = conteoBloc.lineasContadas
              .where((element) => element.isDoneItem == 1)
              .toList();

          final productosPorUbicacion = _groupByLocation(productosContados);

          return Scaffold(
            backgroundColor: white,
            body: Container(
              margin: const EdgeInsets.only(top: 5),
              width: double.infinity,
              height: size.height * 0.8,
              child: Column(
                children: [
                  productosPorUbicacion.isEmpty
                      ? ProductEmpty()
                      : Expanded(
                          child: ListView.builder(
                            itemCount: productosPorUbicacion.length,
                            itemBuilder: (context, index) {
                              final ubicacion =
                                  productosPorUbicacion.keys.elementAt(index);
                              final productos =
                                  productosPorUbicacion[ubicacion]!;

                              return CustomExpansionTileSinBloc(
                                key: ValueKey(ubicacion.toLowerCase()),
                                title: ubicacion,
                                subtitle: '${productos.length} producto(s)',
                                children: productos
                                    .map((product) =>
                                        _buildProductItem(product, size))
                                    .toList(),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductItem(CountedLine product, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Producto", product.productName ?? ''),
              _buildInfoRow("Código", product.productCode ?? ''),
              _buildInfoRow(
                  "Cantidad contada", product.quantityCounted.toString()),
              _buildInfoRow("Novedad", product.observation.toString()),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: primaryColorApp,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Tiempo: ",
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColorApp,
                    ),
                  ),
                  Text(convertirTiempo(product.time.toString()),
                      style: const TextStyle(fontSize: 12, color: black)),
                ],
              ),
              if (product.productTracking == 'lot')
                _buildInfoRow("Lote", product.lotName ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  String convertirTiempo(String tiempoStr) {
    // Convertimos el string a un double
    double segundos = double.tryParse(tiempoStr) ?? 0.0;
    // Calculamos horas, minutos y segundos
    int horas = (segundos / 3600).floor(); // 3600 segundos = 1 hora
    int minutos =
        ((segundos % 3600) / 60).floor(); // Resto de segundos dividido entre 60
    int segundosRestantes = (segundos % 60).round(); // Resto de segundos
    // Formateamos los valores en 2 dígitos (ej. 01, 02, etc.)
    String horasStr = horas.toString().padLeft(2, '0');
    String minutosStr = minutos.toString().padLeft(2, '0');
    String segundosStr = segundosRestantes.toString().padLeft(2, '0');

    return '$horasStr:$minutosStr:$segundosStr';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 12,
              color: primaryColorApp,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value == "" ? "Sin $label" : value,
              style: TextStyle(fontSize: 12, color: value == "" ? red : black),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomExpansionTileSinBloc extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const CustomExpansionTileSinBloc({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  State<CustomExpansionTileSinBloc> createState() =>
      _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTileSinBloc> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[200],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            onTap: _toggleExpanded,
            title: Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColorApp,
              ),
            ),
            subtitle: Text(
              widget.subtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Column(children: widget.children),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
