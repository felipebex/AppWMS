import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wms_app/src/presentation/views/home/bloc/home_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

class UpdateAppDialog extends StatefulWidget {
  const UpdateAppDialog({
    super.key,
  });

  @override
  _UpdateAppDialogState createState() => _UpdateAppDialogState();
}

class _UpdateAppDialogState extends State<UpdateAppDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // Para saber en qué página estamos

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return AlertDialog(
          // actionsAlignment: MainAxisAlignment.center,
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'Nueva Actualización Disponible ${context.read<HomeBloc>().appVersion.result?.result?.version ?? ''}',
              style: TextStyle(color: primaryColorApp, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite, // Ajustamos el ancho del dialogo
            height: 300,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Primera página: Novedades de la actualización
                _buildNewFeaturesPage(),
                // Segunda página: Instrucciones para actualizar
                _buildInstructionsPage(),
              ],
            ),
          ),
          actions: [
            if (_currentPage == 1) ...[
              // Solo mostramos los botones cuando estamos en la página de instrucciones
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(200, 40),
                    ),
                    child: Text(
                      "Recordar Más Tarde",
                      style: TextStyle(color: white, fontSize: 14),
                    )),
              ),

              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      print(context
                          .read<HomeBloc>()
                          .appVersion
                          .result
                          ?.result
                          ?.urlDownload);

                      //abrimos el navegador con la url de descarga
                      await launch(context
                              .read<HomeBloc>()
                              .appVersion
                              .result
                              ?.result
                              ?.urlDownload ??
                          '');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColorApp,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(200, 40),
                    ),
                    child: Text(
                      "Actualizar",
                      style: TextStyle(color: white, fontSize: 14),
                    )),
              ),
            ],
          ],
        );
      },
    );
  }

  // Función para mostrar las novedades
  Widget _buildNewFeaturesPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 200,
          child: Image.asset(
            "assets/images/icono2.jpeg",
            fit: BoxFit.cover,
          ),
        ),
      
       
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.read<HomeBloc>().appVersion.result?.result?.notes ?? '',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 14),
          ),
        ),
        Spacer(),
        Center(
          child: ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColorApp,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Siguiente",
                style: TextStyle(color: white, fontSize: 14),
              )),
        )
      ],
    );
  }

  String _formatDate(String? releaseDate) {
    if (releaseDate == null) return '';

    // Si la fecha está en formato String, convertirla a DateTime
    DateTime dateTime = DateTime.parse(releaseDate);

    // Usar DateFormat para formatear la fecha
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

    return formattedDate;
  }

  // Función para mostrar las instrucciones para la actualización
  Widget _buildInstructionsPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Instrucciones para actualizar:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "Para actualizar la aplicación, presiona el botón de actualizar y descarga la nueva versión de la aplicación, "
          "una vez descargada, desinstala la versión actual y cierra sesion para agrantizar una actualizacion correcta despues procede a instalar la nueva versión.",
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
