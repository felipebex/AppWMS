import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/models/picking_batch_model.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class ProductScannerWidget extends StatelessWidget {
  final bool isProductOk;
  final bool productIsOk;
  final bool locationIsOk;
  final bool quantityIsOk;
  final bool locationDestIsOk;
  final String currentProductId;
  final String? barcode;
  final String? lotId;
  final String? origin;
  final String? expireDate;
  final Size size;
  final Function(String) onValidateProduct;
  final Function(String keyLabel)? onKeyScanned;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Widget productDropdown;
  final Widget expiryWidget;
  final List<Barcodes> listOfBarcodes;
  final VoidCallback onBarcodesDialogTap;
  final String category;
  final bool isViewLote;

  const ProductScannerWidget({
    super.key,
    required this.isProductOk,
    required this.productIsOk,
    required this.locationIsOk,
    required this.quantityIsOk,
    required this.locationDestIsOk,
    required this.currentProductId,
    required this.barcode,
    required this.lotId,
    required this.origin,
    required this.expireDate,
    required this.size,
    required this.onValidateProduct,
    this.onKeyScanned,
    required this.focusNode,
    required this.controller,
    required this.productDropdown,
    required this.expiryWidget,
    required this.listOfBarcodes,
    required this.onBarcodesDialogTap,
    this.category = "",
    this.isViewLote = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: productIsOk ? green : yellow,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Card(
          color: isProductOk
              ? productIsOk
                  ? Colors.green[100]
                  : Colors.grey[300]
              : Colors.red[200],
          elevation: 5,
          child: Container(
            width: size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: !context.read<UserBloc>().fabricante.contains("Zebra")
                ? Focus(
                    focusNode: focusNode,
                    onKey: (node, event) {
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          onValidateProduct(controller.text);
                          return KeyEventResult.handled;
                        } else {
                          if (onKeyScanned != null) {
                            onKeyScanned!(event.data.keyLabel);
                          }
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        productDropdown,
                        Text(currentProductId,
                            style: TextStyle(
                                fontSize: 12,
                                color: black)),
                        const SizedBox(height: 10),
                       
                        Row(
                          children: [
                            Image.asset(
                              "assets/icons/barcode.png",
                              color: primaryColorApp,
                              width: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              (barcode == null ||
                                      barcode!.isEmpty ||
                                      barcode == "false")
                                  ? "Sin codigo de barras"
                                  : barcode!,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: (barcode == null ||
                                          barcode!.isEmpty ||
                                          barcode == "false")
                                      ? Colors.red
                                      : black),
                            ),
                          ],
                        ),
                         if (category != "")
                          Row(
                            children: [
                              Text('Categoria:',
                                  style: TextStyle(
                                      fontSize: 13, color: primaryColorApp)),
                              const SizedBox(width: 5),
                              Text(category,
                                  style: const TextStyle(
                                      fontSize: 13, color: black)),
                            
                            ],
                          ),
                        if(isViewLote)...[
                        if (lotId != null)
                          Row(
                            children: [
                              Text('Lote/serie:',
                                  style: TextStyle(
                                      fontSize: 13, color: primaryColorApp)),
                              const SizedBox(width: 5),
                              Text(lotId!,
                                  style: const TextStyle(
                                      fontSize: 13, color: black)),
                              const Spacer(),
                              GestureDetector(
                                onTap: onBarcodesDialogTap,
                                child: Visibility(
                                  visible: listOfBarcodes.isNotEmpty,
                                  child: Image.asset(
                                      "assets/icons/package_barcode.png",
                                      color: primaryColorApp,
                                      width: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (origin != null && origin!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.file_open_sharp,
                                  color: primaryColorApp, size: 15),
                              const SizedBox(width: 5),
                              const Text("Doc. origen: ",
                                  style: TextStyle(fontSize: 12, color: grey)),
                              Text(origin!,
                                  style: TextStyle(
                                      fontSize: 12, color: primaryColorApp)),
                            ],
                          ),
                        expiryWidget,
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      productDropdown,
                      TextFormField(
                        showCursor: false,
                        enabled: locationIsOk &&
                            !productIsOk &&
                            !quantityIsOk &&
                            !locationDestIsOk,
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) {
                          onValidateProduct(value);
                        },
                        decoration: InputDecoration(
                          hintText: currentProductId,
                          hintMaxLines: 2,
                          disabledBorder: InputBorder.none,
                          hintStyle:
                              const TextStyle(fontSize: 12, color: black),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            "assets/icons/barcode.png",
                            color: primaryColorApp,
                            width: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            (barcode == null ||
                                    barcode!.isEmpty ||
                                    barcode == "false")
                                ? "Sin codigo de barras"
                                : barcode!,
                            style: TextStyle(
                                fontSize: 12,
                                color: (barcode == null ||
                                        barcode!.isEmpty ||
                                        barcode == "false")
                                    ? red
                                    : black),
                          ),
                        ],
                      ),
                      if(isViewLote)...[
                      if (lotId != null)
                        Row(
                          children: [
                            Text('Lote/serie:',
                                style: TextStyle(
                                    fontSize: 13, color: primaryColorApp)),
                            const SizedBox(width: 5),
                            Text(lotId!,
                                style: const TextStyle(
                                    fontSize: 13, color: black)),
                            const Spacer(),
                            GestureDetector(
                              onTap: onBarcodesDialogTap,
                              child: Visibility(
                                visible: listOfBarcodes.isNotEmpty,
                                child: Image.asset(
                                    "assets/icons/package_barcode.png",
                                    color: primaryColorApp,
                                    width: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (origin != null && origin!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.file_open_sharp,
                                color: primaryColorApp, size: 15),
                            const SizedBox(width: 5),
                            const Text("Doc. origen: ",
                                style: TextStyle(fontSize: 12, color: grey)),
                            Text(origin!,
                                style: TextStyle(
                                    fontSize: 12, color: primaryColorApp)),
                          ],
                        ),
                      expiryWidget,
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
