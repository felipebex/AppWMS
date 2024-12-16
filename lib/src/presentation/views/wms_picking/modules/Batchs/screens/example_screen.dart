import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PDAScannerScreen extends StatefulWidget {
  const PDAScannerScreen({super.key});

  @override
  _PDAScannerScreenState createState() => _PDAScannerScreenState();
}

class _PDAScannerScreenState extends State<PDAScannerScreen> {
  String scannedValue1 = '';
  String scannedValue2 = '';

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mover la solicitud de foco aquí
    FocusScope.of(context).requestFocus(focusNode1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDA Scanner Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("focusNode1: ${focusNode1.hasFocus}"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("focusNode2: ${focusNode2.hasFocus}"),
          ),
          const Divider(),
          Focus(
            focusNode: focusNode1,
            onKey: (FocusNode node, RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  if (scannedValue1.isNotEmpty) {
                    print('Escaneado 1: $scannedValue1');
                    FocusScope.of(context).requestFocus(focusNode2);
                  }
                  return KeyEventResult.handled;
                } else {
                  setState(() {
                    scannedValue1 += event.data.keyLabel;
                  });
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Escaneado 1: $scannedValue1',
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Focus(
            focusNode: focusNode2,
            onKey: (FocusNode node, RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  print('Escaneado 2: $scannedValue2');
                  return KeyEventResult.handled;
                } else {
                  setState(() {
                    scannedValue2 += event.data.keyLabel;
                  });
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Escaneado 2: $scannedValue2',
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
