import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  XFile? _imageFile;
  bool _isAnalyzing = false;

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<File> _preprocessImage(String path) async {
    final imageBytes = await File(path).readAsBytes();
    final original = img.decodeImage(imageBytes);
    if (original == null) throw Exception("No se pudo procesar la imagen");

    final grayscale = img.grayscale(original);
    final highContrast = img.adjustColor(grayscale, contrast: 1.5);
    final processedBytes = img.encodeJpg(highContrast);

    final directory = await getTemporaryDirectory();
    final newPath = p.join(directory.path, 'processed.jpg');
    return File(newPath)..writeAsBytesSync(processedBytes);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OCR - Captura Temperatura")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("Tomar Foto"),
              onPressed: _pickImageFromCamera,
            ),
            const SizedBox(height: 20),
            _imageFile != null
                ? Image.file(File(_imageFile!.path), height: 300)
                : Text("No hay imagen seleccionada"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
