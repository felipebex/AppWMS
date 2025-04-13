import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_bloc.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_event.dart';
import 'package:wms_app/src/presentation/blocs/keyboard/keyboard_state.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class CustomKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onchanged;
  final bool isLogin;

  const CustomKeyboard({
    super.key,
    required this.controller,
    required this.onchanged,
    required this.isLogin,
  });

  @override
  _CustomKeyboardState createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool isCapsEnabled = false;
  bool isNumericMode = false;

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
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isNumericMode
              ? _buildNumericKeyboard()
              : _buildAlphabetKeyboard(),
        ),
      ),
    );
  }

  List<Widget> _buildAlphabetKeyboard() {
    return [
      Row(
          children: _buildLetterRow(
              ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'])),
      Row(
          children: _buildLetterRow(
              ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ñ'])),
      Row(
        children: [
          _buildCapsLockButton(),
          ..._buildLetterRow(['z', 'x', 'c', 'v', 'b', 'n', 'm']),
          _buildBackspaceButton(false),
        ],
      ),
      Row(
        children: [
          _buildSwitchModeButton("?123"),
          _buildSpecialButton(','),
          _buildSpaceButton(),
          _buildSpecialButton('.'),
          Visibility(visible: widget.isLogin, child: _buildConfirmButton()),
        ],
      ),
    ];
  }

  List<Widget> _buildNumericKeyboard() {
    return [
      Row(
          children: _buildSpecialRow(
              ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'])),
      Row(
          children: _buildSpecialRow(
              ['@', '#', '\$', '_', '&', '-', '+', '(', ')', '/'])),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildSpecialRow(['*', '\'', '"', ':', ';', '!', '?']) +
              [_buildBackspaceButton(true)]),
      Row(
        children: [
          _buildSwitchModeButton("ABC"),
          _buildSpecialButton(','),
          _buildSpaceButton(),
          _buildSpecialButton('.'),
          Visibility(visible: widget.isLogin, child: _buildConfirmButton()),
        ],
      ),
    ];
  }

  List<Widget> _buildLetterRow(List<String> letters) {
    return letters.map((letter) {
      final display = isCapsEnabled ? letter.toUpperCase() : letter;
      return _buildKey(display);
    }).toList();
  }

  List<Widget> _buildSpecialRow(List<String> symbols) {
    return symbols.map((s) => _buildKey(s)).toList();
  }

  Widget _buildKey(String key) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      width: 34,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context
              .read<KeyboardBloc>()
              .add(KeyPressedEvent(key, widget.controller));
        },
        child: Center(
          child: Text(
            key,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialButton(String key) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context
            .read<KeyboardBloc>()
            .add(KeyPressedEvent(key, widget.controller));
      },
      child: _buildKey(key),
    );
  }

  Widget _buildBackspaceButton(bool isNumber) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context
            .read<KeyboardBloc>()
            .add(BackspacePressedEvent(widget.controller));
      },
      child: Container(
        decoration: BoxDecoration(
          color: white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        width: isNumber ? 50 : 45,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Icon(
          Icons.backspace,
          color: primaryColorApp,
        ),
      ),
    );
  }

  Widget _buildCapsLockButton() {
    return

        // IconButton(
        //   onPressed: () {
        //     HapticFeedback.selectionClick();
        //     setState(() {
        //       isCapsEnabled = !isCapsEnabled;
        //     });
        //   },
        //   icon: Icon(
        //     isCapsEnabled ? Icons.keyboard_capslock : Icons.keyboard,
        //     color: primaryColorApp,
        //   ),
        // );

        GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          isCapsEnabled = !isCapsEnabled;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        width: 50,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Icon(
          isCapsEnabled ? Icons.keyboard_capslock : Icons.keyboard,
          color: primaryColorApp,
        ),
      ),
    );
  }

  Widget _buildSpaceButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context
            .read<KeyboardBloc>()
            .add(KeyPressedEvent(' ', widget.controller));
      },
      child: Container(
        width: 160,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
          color: white,
        ),
        child: const Center(child: Text(' ', style: TextStyle(fontSize: 16))),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context
            .read<KeyboardBloc>()
            .add(KeyPressedEvent('.com', widget.controller));
      },
      child: Container(
        width: 50,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: primaryColorApp,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Center(
          child:
              Text('.com', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildSwitchModeButton(String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          isNumericMode = !isNumericMode;
        });
      },
      child: Container(
        width: 60,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: primaryColorApp,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: white))),
      ),
    );
  }
}
