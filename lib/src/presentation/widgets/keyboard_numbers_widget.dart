import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_bloc.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_event.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_state.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class CustomKeyboardNumber extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onchanged;
  final bool isDialog;

  const CustomKeyboardNumber({
    super.key,
    required this.controller,
    required this.onchanged,
    this.isDialog = false,
  });

  @override
  _CustomKeyboardNumberState createState() => _CustomKeyboardNumberState();
}

class _CustomKeyboardNumberState extends State<CustomKeyboardNumber> {
  bool isCapsEnabled = false; // Estado para el control de mayúsculas

  @override
  Widget build(BuildContext context) {
    return BlocListener<KeyboardBloc, KeyboardState>(
      listener: (context, state) {
        if (state is KeyboardUpdatedState && widget.isDialog) {
          widget.onchanged();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        padding:  EdgeInsets.symmetric(horizontal: 
        widget.isDialog ? 10 : 20.0, vertical:  5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(children: _buildNumberRow(['1', '2', '3'])),
            Row(children: _buildNumberRow(['4', '5', '6'])),
            Row(children: _buildNumberRow(['7', '8', '9'])),
            Row(
              children: [
                // _buildConfirmButton(),
                // const SizedBox(width: 3),
                _buildNumberButton2(','),
                _buildNumberButton2('.'),
                _buildNumberButton2('0'),
                const SizedBox(width: 3),
                _buildBackspaceButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Construye las filas de números
  List<Widget> _buildNumberRow(List<String> numbers) {
    return numbers.map((number) => _buildNumberButton(number)).toList();
  }

  // Crea el botón para los números
  Widget _buildNumberButton2(String key) {
    return GestureDetector(
      onTap: () {
        context
            .read<KeyboardBloc>()
            .add(KeyPressedEvent(key, widget.controller));
      },
      child: Container(
        width:
        widget.isDialog ? 48 :
         77, // Tamaño ajustado
        height: 30, // Tamaño 5justado
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
        decoration: BoxDecoration(
          color: white, // Color blanco de fondo
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(fontSize: 20), // Tamaño del texto ajustado
          ),
        ),
      ),
    );
  }
  Widget _buildNumberButton(String key) {
    return GestureDetector(
      onTap: () {
        context
            .read<KeyboardBloc>()
            .add(KeyPressedEvent(key, widget.controller));
      },
      child: Container(
        width:
        widget.isDialog ? 64 :
         100, // Tamaño ajustado
        height: 30, // Tamaño 5justado
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
        decoration: BoxDecoration(
          color: white, // Color blanco de fondo
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(fontSize: 20), // Tamaño del texto ajustado
          ),
        ),
      ),
    );
  }

  // Botón de "OK" para confirmar
  // Widget _buildConfirmButton() {
  //   return GestureDetector(
  //     onTap: () {
  //       widget.onchanged();
  //     },
  //     child: Container(
  //       width: 
  //       widget.isDialog ? 64 :
  //       50, // Tamaño ajustado
  //       height: 30, // Tamaño ajustado
  //       margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
  //       decoration: BoxDecoration(
  //         color: primaryColorApp,
  //         borderRadius: BorderRadius.circular(5),
  //       ),
  //       child: const Center(
  //         child: Text(
  //           'OK',
  //           style: TextStyle(color: Colors.white, fontSize: 16),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Botón de borrar
  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: () {
        context
            .read<KeyboardBloc>()
            .add(BackspacePressedEvent(widget.controller));
      },
      child: Container(
        width: 
        widget.isDialog ? 45 :
        60, // Tamaño ajustado
        height: 30,
        decoration: BoxDecoration(
          color: primaryColorApp,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Icon(Icons.backspace, color: white),
      ),
    );
  }
}
