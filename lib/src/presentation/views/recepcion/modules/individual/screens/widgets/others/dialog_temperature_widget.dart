import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class DialogCapturaTemperatura extends StatefulWidget {
  final int moveLineId;

  const DialogCapturaTemperatura({super.key, required this.moveLineId});

  @override
  State<DialogCapturaTemperatura> createState() =>
      _DialogCapturaTemperaturaState();
}

class _DialogCapturaTemperaturaState extends State<DialogCapturaTemperatura> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _tomarFoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RecepcionBloc>();

    return BlocConsumer<RecepcionBloc, RecepcionState>(
      listener: (context, state) {
        if (state is GetTemperatureFailure) {
          Get.defaultDialog(
            title: '360 Software Informa',
            titleStyle: const TextStyle(color: Colors.red, fontSize: 18),
            middleText: state.error,
            middleTextStyle: const TextStyle(color: black, fontSize: 14),
            backgroundColor: Colors.white,
            radius: 10,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColorApp,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Aceptar', style: TextStyle(color: white)),
              ),
            ],
          );
        }
      },
      builder: (context, state) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: AlertDialog(
            title:  Center(
              child: Text(
                "Captura la temperatura ${widget.moveLineId}",
                style: TextStyle(fontSize: 16, color: black),
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_imageFile == null) ...[
                    const Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text(
                      'Debes tomar una foto para capturar la temperatura',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: black),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _tomarFoto,
                      icon: const Icon(Icons.camera, color: white),
                      label: const Text('Tomar foto',
                          style: TextStyle(fontSize: 14, color: white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColorApp,
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.fill,
                        height: 300,
                        width: 250,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _tomarFoto,
                          icon: Icon(Icons.refresh, color: primaryColorApp),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<RecepcionBloc>().add(
                                  GetTemperatureEvent(file: _imageFile!),
                                );
                          },
                          icon: const Icon(Icons.image_search_sharp),
                          label: const Text("Analizar"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildTemperatureResult(bloc),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemperatureResult(RecepcionBloc bloc) {
    return Column(
      children: [
        Card(
          color: white,
          elevation: 2,
          child: ListTile(
            title: RichText(
              text: TextSpan(
                text: 'Temperatura: ',
                style: const TextStyle(color: black, fontSize: 12),
                children: [
                  TextSpan(
                    text: bloc.resultTemperature.temperature == null
                        ? '0.0'
                        : bloc.resultTemperature.temperature.toString() ??
                            '0.0',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: primaryColorApp,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Unidad: ',
                    style: const TextStyle(color: black, fontSize: 12),
                    children: [
                      TextSpan(
                        text: bloc.resultTemperature.unit ?? 'Sin unidad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColorApp,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Confianza: ',
                    style: TextStyle(color: primaryColorApp, fontSize: 12),
                    children: [
                      TextSpan(
                        text: bloc.resultTemperature.confidence ??
                            'Sin confianza',
                        style: const TextStyle(fontSize: 12, color: black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed:
              _imageFile != null && bloc.resultTemperature.temperature != null
                  ? () {
                      bloc.add(SendTemperatureEvent(
                        file: _imageFile!,
                        moveLineId: widget.moveLineId,
                      ));
                    }
                  : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
            backgroundColor: primaryColorApp,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: const Text("Enviar",
              style: TextStyle(fontSize: 14, color: white)),
        ),
      ],
    );
  }
}
