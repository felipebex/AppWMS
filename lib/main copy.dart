

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'PDA Scanner Example',
//       home: PDAScannerScreen(),
//     );
//   }
// }

// class PDAScannerScreen extends StatefulWidget {
//   const PDAScannerScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _PDAScannerScreenState createState() => _PDAScannerScreenState();
// }

// class _PDAScannerScreenState extends State<PDAScannerScreen> {
//   String scannedValue1 = '';
//   String scannedValue2 = '';

//   FocusNode focusNode1 = FocusNode();
//   FocusNode focusNode2 = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDA Scanner Example'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Focus(
//             focusNode: focusNode1,
//             onKey: (FocusNode node, RawKeyEvent event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.enter) {
//                   print('Escaneado 1:: $scannedValue1');
//                   FocusScope.of(context).requestFocus(focusNode2);
//                   return KeyEventResult.handled;
//                 } else {
//                   setState(() {
//                     scannedValue1 += event.data.keyLabel;
//                   });
//                   return KeyEventResult.handled;
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.center_focus_strong),
//                         onPressed: () {
//                           FocusScope.of(context).requestFocus(focusNode1);
//                         },
//                       ),
//                     ],
//                   ),
//                   Text(
//                     'Escaneado 1: $scannedValue1',
//                     style: const TextStyle(fontSize: 24),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const Divider(),
//           Focus(
//             focusNode: focusNode2,
//             onKey: (FocusNode node, RawKeyEvent event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.enter) {
//                   print('Escaneado 2: $scannedValue2');
//                   return KeyEventResult.handled;
//                 } else {
//                   setState(() {
//                     scannedValue2 += event.data.keyLabel;
//                   });
//                   return KeyEventResult.handled;
//                 }
//               }

//               return KeyEventResult.ignored;
//             },
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Escaneado 2: $scannedValue2',
//                     style: const TextStyle(fontSize: 24),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
