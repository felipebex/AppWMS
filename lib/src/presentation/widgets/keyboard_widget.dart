import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_bloc.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_event.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_state.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class CustomKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onchanged;

  const CustomKeyboard({
    super.key,
    required this.controller,
    required this.onchanged,
  });

  @override
  _CustomKeyboardState createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool isCapsEnabled = false; // Estado para el control de mayúsculas

  @override
  Widget build(BuildContext context) {
    return BlocListener<KeyboardBloc, KeyboardState>(
      listener: (context, state) {
        if (state is KeyboardUpdatedState) {
          widget.onchanged();
        }
      },
      child: Container(
        color: lightGrey,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: _buildNumberRow(['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'])),
            Row(children: _buildLetterRow(['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'])),
            Row(children: _buildLetterRow(['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ñ'])),
            Row(
              children: [
                _buildCapsLockButton(),
                Row(children: _buildLetterRow(['z', 'x', 'c', 'v', 'b', 'n', 'm'])),
                IconButton(
                  onPressed: () {
                    context.read<KeyboardBloc>().add(BackspacePressedEvent(widget.controller));
                  },
                  icon: const Icon(Icons.backspace),
                ),
              ],
            ),
            Row(
              children: [
                _buildSpecialButton(','),
                _buildSpecialButton('/'),
                _buildSpaceButton(),
                _buildSpecialButton('@'),
                _buildSpecialButton('.'),
                _buildSpecialButton(':'),
                _buildConfirmButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }



  List<Widget> _buildNumberRow(List<String> numbers) {
    return numbers.map((number) => _buildKey(number)).toList();
  }

  List<Widget> _buildLetterRow(List<String> letters) {
    return letters.map((letter) {
      return _buildKey(isCapsEnabled ? letter.toUpperCase() : letter);
    }).toList();
  }

  // Método común para crear una tecla sin animación
  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () {
        context.read<KeyboardBloc>().add(KeyPressedEvent(key, widget.controller));
      },
      child: Container(
        width: 30, // Ajustamos el ancho de las teclas
        height: 40, // Ajustamos el alto de las teclas
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        decoration: BoxDecoration(
          color: white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
  

  // Crear un botón especial sin animación
  Widget _buildSpecialButton(String key) {
    return GestureDetector(
      onTap: () {
        context.read<KeyboardBloc>().add(KeyPressedEvent(key, widget.controller));
      },
      child: _buildKey(key),
    );
  }

  Widget _buildSpaceButton() {
    return GestureDetector(
      onTap: () {
        context.read<KeyboardBloc>().add(KeyPressedEvent(' ', widget.controller));
      },
      child: Container(
        width: 112,
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
          color: white,
        ),
        child: const Center(
          child: Text(' ', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () {
        context.read<KeyboardBloc>().add(ConfirmPressedEvent(widget.controller));
      },
      child: Container(
        width: 50,
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        decoration: BoxDecoration(
          color: primaryColorApp,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Center(
          child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildCapsLockButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          isCapsEnabled = !isCapsEnabled;
        });
      },
      icon: Icon(
        isCapsEnabled ? Icons.keyboard_capslock : Icons.keyboard,
        color: primaryColorApp,
      ),
    );
  }
}
