import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart'as esc_pos;
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String _info = "";
  String _msj = '';
  bool connected = false;
  List<BluetoothInfo> items = [];
  final List<String> _options = ["Permiso bluetooth concedido", "bluetooth activado", "connection status", "update info"];

  String _selectSize = "2";
  final _txtText = TextEditingController(text: "Hello developer");
  bool _progress = false;
  String _msjprogress = "";

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            PopupMenuButton(
              elevation: 3.2,
              onCanceled: () {
                print('You have not chosen anything');
              },
              tooltip: 'Menu',
              onSelected: (Object select) async {
                String sel = select as String;
                if (sel == "Permiso bluetooth concedido") {
                  bool status = await PrintBluetoothThermal.isPermissionBluetoothGranted;
                  setState(() {
                    _info = "Permiso bluetooth concedido: $status";
                  });
                } else if (sel == "bluetooth activado") {
                  bool state = await PrintBluetoothThermal.bluetoothEnabled;
                  setState(() {
                    _info = "Bluetooth activado: $state";
                  });
                } else if (sel == "update info") {
                  initPlatformState();
                } else if (sel == "connection status") {
                  final bool result = await PrintBluetoothThermal.connectionStatus;
                  connected = result;
                  setState(() {
                    _info = "Estado de conexión: $result";
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                return _options.map((String option) {
                  return PopupMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('info: $_info\n '),
                Text(_msj),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tipo de impresión"),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: optionprinttype,
                      items: options.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          optionprinttype = newValue!;
                        });
                      },
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          getBluetoots();
                        },
                        child: Row(
                          children: [
                            Visibility(
                              visible: _progress,
                              child: const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator.adaptive(strokeWidth: 1, backgroundColor: Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(_progress ? _msjprogress : "Buscar"),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: connected ? disconnect : null,
                        child: const Text("Desconectar"),
                      ),
                      ElevatedButton(
                        onPressed: connected ? printTest : null,
                        child: const Text("Prueba"),
                      ),
                    ],
                  ),
                ),
                Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey.withAlpha(50),
                    ),
                    child: ListView.builder(
                      itemCount: items.isNotEmpty ? items.length : 0,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            String mac = items[index].macAdress;
                            connect(mac);
                          },
                          title: Text('Nombre: ${items[index].name}'),
                          subtitle: Text("Dirección MAC: ${items[index].macAdress}"),
                        );
                      },
                    )),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey.withAlpha(50),
                  ),
                  child: Column(children: [
                    const Text("Tamaño de texto sin usar paquetes externos, imprimir imágenes sin usar una librería"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _txtText,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Texto",
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        DropdownButton<String>(
                          hint: const Text('Tamaño'),
                          value: _selectSize,
                          items: <String>['1', '2', '3', '4', '5'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? select) {
                            setState(() {
                              _selectSize = select.toString();
                            });
                          },
                        )
                      ],
                    ),
                    ElevatedButton(
                      onPressed: connected ? printTest : null,
                      child: const Text("Imprimir"),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } catch (e) {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    print("Bluetooth activado: $result");
    if (result) {
      _msj = "Bluetooth activado, por favor busca y conecta";
    } else {
      _msj = "Bluetooth no activado";
    }

    setState(() {
      _info = "$platformVersion ($porcentbatery% batería)";
    });
  }

  Future<void> getBluetoots() async {
    setState(() {
      _progress = true;
      _msjprogress = "Espera";
      items = [];
    });
    final List<BluetoothInfo> listResult = await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      _progress = false;
    });

    if (listResult.isEmpty) {
      _msj = "No hay bluetooths vinculados, ve a ajustes y vincula la impresora";
    } else {
      _msj = "Toca un elemento de la lista para conectar";
    }

    setState(() {
      items = listResult;
    });
  }

  Future<void> connect(String mac) async {
    setState(() {
      _progress = true;
      _msjprogress = "Conectando...";
      connected = false;
    });
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    print("Estado conectado $result");
    if (result) connected = true;
    setState(() {
      _progress = false;
    });
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
    });
    print("Estado desconectado $status");
  }

  Future<void> printTest() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conexionStatus) {
      bool result = false;
        List<int> ticket = await testTicket();
        result = await PrintBluetoothThermal.writeBytes(ticket);
      print("Resultado de la prueba de impresión:  $result");
    } else {
      print("Estado de conexión de la prueba de impresión: $conexionStatus");
      setState(() {
        disconnect();
      });
    }
  }
Future<List<int>> testTicket() async {
  List<int> bytes = [];
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile); // Ajusta el tamaño del papel según sea necesario
  bytes += generator.reset();

  // Texto
  bytes += generator.text('Texto de ejemplo', styles: const PosStyles(align: PosAlign.center, bold: true));
  bytes += generator.text('https://example.com', styles: const PosStyles(align: PosAlign.center));

  // Generar el código QR como Uint8List
  final Uint8List qrUint8List = await _generateQrUint8List();

  // Convertir Uint8List a una imagen manipulable
  final img.Image? qrImage = img.decodeImage(qrUint8List);

  // Agregar la imagen del código QR a los bytes de impresión
  if (qrImage != null) {
    bytes += generator.image(qrImage);
  }

  bytes += generator.feed(2);
  bytes += generator.cut();
  return bytes;
}

Future<Uint8List> _generateQrUint8List() async {
  // Crear un PictureRecorder para capturar la imagen
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Generar el código QR
  final qrPainter = QrPainter(
    data: 'https://example.com',
    version: QrVersions.auto,
    color: Colors.black,
    emptyColor: Colors.white,
  );

  // Definir el tamaño del código QR
  const qrSize = 200.0;
  qrPainter.paint(canvas, const Size(qrSize, qrSize));

  // Convertir el PictureRecorder en una imagen
  final picture = recorder.endRecording();
  final image = await picture.toImage(qrSize.toInt(), qrSize.toInt());

  // Convertir la imagen en bytes (Uint8List)
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  return pngBytes;
}



}