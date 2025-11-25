import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wms_app/src/core/constans/colors.dart';
import 'package:wms_app/src/core/utils/theme/input_decoration.dart';

class QuantityScannerWidget extends StatelessWidget {
  final Size size;
  final bool isQuantityOk;
  final bool quantityIsOk;
  final bool locationIsOk;
  final bool productIsOk;
  final bool locationDestIsOk;
  final dynamic totalQuantity;
  final dynamic quantitySelected;
  final String unidades;
  final TextEditingController controller;
  final TextEditingController manualController;
  final FocusNode scannerFocusNode;
  final FocusNode manualFocusNode;
  final bool viewQuantity;
  final bool showKeyboard;
  final VoidCallback onToggleViewQuantity;
  final VoidCallback onValidateButton;
  final VoidCallback onIconButtonPressed;
  final Function(String) onValidateScannerInput;
  final Function(String) onManualQuantityChanged;
  final Function(String) onManualQuantitySubmitted;
  final Function(String) onKeyScanned;
  final Widget? customKeyboard;

  bool isViewCant;

  QuantityScannerWidget({
    super.key,
    required this.size,
    required this.isQuantityOk,
    required this.quantityIsOk,
    required this.locationIsOk,
    required this.productIsOk,
    required this.locationDestIsOk,
    required this.totalQuantity,
    required this.quantitySelected,
    required this.unidades,
    required this.controller,
    required this.manualController,
    required this.scannerFocusNode,
    required this.manualFocusNode,
    required this.viewQuantity,
    required this.showKeyboard,
    required this.onToggleViewQuantity,
    required this.onValidateButton,
    required this.onValidateScannerInput,
    required this.onManualQuantityChanged,
    required this.onManualQuantitySubmitted,
    required this.onKeyScanned,
    required this.onIconButtonPressed,
    this.customKeyboard,
    this.isViewCant = true,
  });

  Color _getColorForDifference(dynamic difference) {
    if (difference == 0) {
      return Colors.transparent; // Ocultar el texto cuando la diferencia es 0
    } else if (difference > 10) {
      // Si la diferencia es mayor a 10
      return Colors.red; // Rojo para una gran diferencia
    } else if (difference > 5) {
      // Si la diferencia es mayor a 5 pero menor o igual a 10
      return Colors.orange; // Naranja para una diferencia moderada
    } else {
      // Si la diferencia es 5 o menos
      return Colors.green; // Verde cuando esté cerca de la cantidad pedida
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic difference = (totalQuantity ?? 0) - quantitySelected;

    return SizedBox(
      width: size.width,
      height: viewQuantity && showKeyboard
          ? 300
          : !viewQuantity
              ? 110
              : 150,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              color: isQuantityOk
                  ? quantityIsOk
                      ? Colors.white
                      : Colors.grey[300]
                  : Colors.red[200],
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    if (isViewCant) ...[
                      const Text('Cant:',
                          style: TextStyle(color: black, fontSize: 13)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          totalQuantity?.toStringAsFixed(2) ?? "",
                          style:
                              TextStyle(color: primaryColorApp, fontSize: 13),
                        ),
                      ),
                      if (difference != 0)
                        const Text('Pdte:',
                            style: TextStyle(color: black, fontSize: 13)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: difference == 0
                            ? const SizedBox()
                            : Text(
                                difference
                                    .clamp(0, double.infinity)
                                    .toStringAsFixed(2),
                                style: TextStyle(
                                  color: _getColorForDifference(difference),
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ],
                    Text(unidades,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 13)),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 5),
                        height: 30,
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 5),
                              alignment: Alignment.center,
                              child: Text(
                                quantitySelected.toString(),
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(fontSize: 13, color: black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.none,
                              showCursor: false,
                              textInputAction: TextInputAction.done,
                              enabled: locationIsOk &&
                                  productIsOk &&
                                  quantityIsOk &&
                                  !locationDestIsOk,
                              controller: controller,
                              focusNode: scannerFocusNode,
                              onFieldSubmitted: onValidateScannerInput,
                              style: const TextStyle(color: Colors.transparent),
                              decoration: InputDecoration(
                                hintText: null,
                                hintStyle:
                                    const TextStyle(color: Colors.transparent),
                                disabledBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: quantityIsOk && quantitySelected >= 0
                          ? onToggleViewQuantity
                          : null,
                      icon: Icon(Icons.edit_note_rounded,
                          color: primaryColorApp, size: 25),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (viewQuantity)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: SizedBox(
                height: 35,
                child: TextFormField(
                  focusNode: manualFocusNode,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  controller: manualController,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  onChanged: onManualQuantityChanged,
                  onFieldSubmitted: onManualQuantitySubmitted,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: 'Cantidad',
                    labelText: 'Cantidad',
                    suffixIconButton: IconButton(
                      onPressed: onIconButtonPressed,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton(
              onPressed: quantityIsOk && quantitySelected >= 0
                  ? onValidateButton
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColorApp,
                minimumSize: Size(size.width * 0.93, 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('APLICAR CANTIDAD',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
