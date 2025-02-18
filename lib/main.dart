import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wms_app/src/presentation/providers/network/check_internet_connection.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

final internetChecker = CheckInternetConnection();
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Material App', home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showQRDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Código QR"),
          content: SizedBox(
            height: 250, // Establecemos el tamaño del dialogo
            width: 250,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Esto hace que el contenido sea flexible
              children: [
                QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 20),
                Text("Escanea este código QR"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showQRDialog(context, "https://www.ejemplo.com");
        },
        backgroundColor: primaryColorApp,
        child: const Icon(
          Icons.print,
          color: white,
        ),
      ),
      body: Center(
        child: Text('HomeScreen'),
      ),
    );
  }
}
