import 'package:flutter/material.dart';
import 'package:wms_app/src/core/constans/colors.dart';

class LocationDestScannerWidget extends StatelessWidget {
  final bool isLocationDestOk;
  final bool locationDestIsOk;
  final bool locationIsOk;
  final bool productIsOk;
  final bool quantityIsOk;
  final Size size;
  final String? muelleHint;
  final Function(String) onValidateMuelle;
  final Function(String)? onKeyScanned;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Widget dropdownWidget;

  const LocationDestScannerWidget({
    super.key,
    required this.isLocationDestOk,
    required this.locationDestIsOk,
    required this.locationIsOk,
    required this.productIsOk,
    required this.quantityIsOk,
    required this.size,
    required this.muelleHint,
    required this.onValidateMuelle,
    this.onKeyScanned,
    required this.focusNode,
    required this.controller,
    required this.dropdownWidget,
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
              color: locationDestIsOk ? Colors.green : Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Card(
          color: isLocationDestOk
              ? locationDestIsOk
                  ? Colors.green[100]
                  : Colors.grey[300]
              : Colors.red[200],
          elevation: 5,
          child: Container(
            width: size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child:
                Column(
              children: [
                dropdownWidget,
                const SizedBox(height: 5),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 50.0),
                      child: Text(
                        muelleHint ?? 'Sin muelle',
                        style: const TextStyle(fontSize: 14, color: black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: TextFormField(
                        keyboardType: TextInputType.none,
                        showCursor: false,
                        textInputAction: TextInputAction.done,
                        enabled: locationIsOk &&
                            productIsOk &&
                            !quantityIsOk &&
                            !locationDestIsOk,
                        controller: controller,
                        focusNode: focusNode,
                        onFieldSubmitted: (value) {
                          onValidateMuelle(value);
                        },
                        style: const TextStyle(color: Colors.transparent),
                        decoration: InputDecoration(
                          hintText: null,
                          hintStyle: const TextStyle(color: Colors.transparent),
                          disabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
