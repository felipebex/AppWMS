import 'package:flutter/material.dart';
import 'package:wms_app/src/core/constans/colors.dart';

class LocationScannerWidget extends StatelessWidget {
  final bool isLocationOk;
  final bool locationIsOk;
  final bool productIsOk;
  final bool quantityIsOk;
  final bool locationDestIsOk;
  final String currentLocationId;
  final Function(String) onValidateLocation;
  final Function(String keyLabel)? onKeyScanned;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Widget locationDropdown;

  const LocationScannerWidget({
    super.key,
    required this.isLocationOk,
    required this.locationIsOk,
    required this.productIsOk,
    required this.quantityIsOk,
    required this.locationDestIsOk,
    required this.currentLocationId,
    required this.onValidateLocation,
    this.onKeyScanned,
    required this.focusNode,
    required this.controller,
    required this.locationDropdown,
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
              color: locationIsOk ? Colors.green : Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Card(
          color: isLocationOk
              ? locationIsOk
                  ? Colors.green[100]
                  : Colors.grey[300]
              : Colors.red[200],
          elevation: 5,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child:
                Column(
              children: [
                locationDropdown,
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 50.0),
                      child: Text(
                        currentLocationId,
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
                        enabled: !locationIsOk &&
                            !productIsOk &&
                            !quantityIsOk &&
                            !locationDestIsOk,
                        controller: controller,
                        focusNode: focusNode,
                        onFieldSubmitted: (value) {
                          focusNode.unfocus();
                          onValidateLocation(value);
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
