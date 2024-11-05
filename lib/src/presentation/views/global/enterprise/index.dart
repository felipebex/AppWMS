// // ignore_for_file: use_build_context_synchronously, must_be_immutable, avoid_print

// import 'dart:io';

// import 'package:animate_do/animate_do.dart';
// import 'package:bexwmsapp/src/presentation/views/global/enterprise/bloc/entreprise_bloc.dart';
// import 'package:bexwmsapp/src/presentation/views/global/login/widgets/list_database.dart';
// import 'package:bexwmsapp/src/utils/constans/colors.dart';
// import 'package:bexwmsapp/src/utils/constans/gaps.dart';
// import 'package:bexwmsapp/src/utils/validator.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../widgets/message_modal.dart';

// class SelectEnterpricePage extends StatelessWidget {
//   const SelectEnterpricePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<EntrepriseBloc, EntrepriseState>(
//       listener: (context, state) {
//         //estado de error
//         if (state is EntrepriseFailure) {
//           showModalDialog(context, state.error);
//         }

//         if (state is EntrepriseSuccess) {
//           showModalBottomSheet(
//               context: context,
//               builder: (c) => DetailClientSale(
//                     listDB: context.read<EntrepriseBloc>().entrepriceList,
//                   ));
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           body: Container(
//             width: double.infinity,
//             decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     colors: [primaryColorApp, secondary, primaryColorApp])),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 const SizedBox(
//                   height: 80,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(55),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                           child: FadeIn(
//                               duration: const Duration(microseconds: 3),
//                               child: const Text(
//                                 "Bienvenido a WMS",
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 22),
//                               ))),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       const Center(
//                         child: Text("Version: 1.0.0",
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 10)),
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: Container(
//                     decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(60),
//                             topRight: Radius.circular(60))),
//                     child: SingleChildScrollView(
//                       child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: _LoginForm()),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _LoginForm extends StatelessWidget {
//   _LoginForm();

//   final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<EntrepriseBloc, EntrepriseState>(
//       builder: (context, state) {
//         return Form(
//           key: _formkey,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           child: Column(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(200),
//                 child: Image.asset(
//                   'assets/images/icon.png',
//                   width: 300,
//                   height: 170,
//                 ),
//               ),
//               FadeIn(
//                 duration: const Duration(microseconds: 3),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(25),
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryColorApp.withOpacity(0.3),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         child: Row(
//                           children: [
//                             // Dropdown para seleccionar el protocolo
//                             Container(
//                               margin: const EdgeInsets.only(left: 10),
//                               decoration: const BoxDecoration(
//                                 border: Border(
//                                   bottom: BorderSide
//                                       .none, // Elimina el borde inferior
//                                 ),
//                               ),
//                               child: DropdownButton<String>(
//                                 elevation: 0,
//                                 underline: Container(
//                                   height: 0,
//                                   color: Colors.transparent,
//                                 ),
//                                 value: context.read<EntrepriseBloc>().method,
//                                 items: const [
//                                   DropdownMenuItem(
//                                     value: 'https://',
//                                     child: Text('https://',
//                                         style: TextStyle(color: Colors.black)),
//                                   ),
//                                   DropdownMenuItem(
//                                     value: 'http://',
//                                     child: Text('http://',
//                                         style: TextStyle(color: Colors.black)),
//                                   ),
//                                 ],
//                                 onChanged: (String? newValue) {
//                                   if (newValue != null) {
//                                     // selectedProtocol = newValue;
//                                     context.read<EntrepriseBloc>().add(
//                                         ChangeMethod(
//                                             newValue)); // Cambiar el método
//                                   }
//                                 },
//                               ),
//                             ),
//                             const SizedBox(
//                                 width:
//                                     5), // Espacio entre el dropdown y el TextFormField
//                             // TextFormField para la URL
//                             Expanded(
//                               child: TextFormField(
//                                 autocorrect: false,
//                                 controller: context
//                                     .read<EntrepriseBloc>()
//                                     .entrepriceController,
//                                 decoration: const InputDecoration(
//                                   disabledBorder: OutlineInputBorder(),
//                                   hintText: "Ingrese la URL",
//                                   hintStyle: TextStyle(color: Colors.grey),
//                                   border: InputBorder.none,
//                                 ),
//                                 validator: ((value) =>
//                                     Validator.hasValidDomain(value, context)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (context.read<EntrepriseBloc>().recentUrls.isNotEmpty)
//                 const Padding(
//                   padding: EdgeInsets.only(top: 15, bottom: 10),
//                   child: Text(
//                     'URLs recientes',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               SizedBox(
//                 width: double.infinity,
//                 height: context.read<EntrepriseBloc>().recentUrls.isEmpty
//                     ? 0
//                     : 150, // Altura de la lista de URLs recientes
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(0),
//                   itemCount: context.read<EntrepriseBloc>().recentUrls.length,
//                   itemBuilder: (context, index) {
//                     return Card(
//                       color: Colors.white,
//                       elevation: 2,
//                       child: ListTile(
//                         leading:
//                             const Icon(Icons.history, color: primaryColorApp),
//                         title: Text(
//                             "${context.read<EntrepriseBloc>().recentUrls[index].method}${context.read<EntrepriseBloc>().recentUrls[index].url}",
//                             style: const TextStyle(fontSize: 14)),
//                         trailing: IconButton(
//                           icon: Icon(Icons.delete,
//                               size: 20, color: Colors.grey[400]),
//                           onPressed: () {
//                             context
//                                 .read<EntrepriseBloc>()
//                                 .add(DeleteUrl(
//                                     context
//                                         .read<EntrepriseBloc>()
//                                         .recentUrls[index]
//                                         .url,
//                                     context
//                                         .read<EntrepriseBloc>()
//                                         .recentUrls[index]
//                                         .method));
//                           },
//                         ),
//                         onTap: () {
//                           context.read<EntrepriseBloc>().add(
//                               ChangeMethod(context
//                                   .read<EntrepriseBloc>()
//                                   .recentUrls[index]
//                                   .method)); // Cambiar el método

//                           context.read<EntrepriseBloc>().entrepriceController.text =
//                               context
//                                   .read<EntrepriseBloc>()
//                                   .recentUrls[index]
//                                   .url; // Cambiar la URL
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               gapH40,
//               MaterialButton(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 disabledColor: Colors.grey,
//                 elevation: 0,
//                 color: primaryColorApp,
//                 onPressed: () async {
//                   FocusScope.of(context).unfocus();

//                   if (!_formkey.currentState!.validate()) return;

//                   try {
//                     final result = await InternetAddress.lookup('example.com');
//                     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//                       // Concatenar el protocolo seleccionado con el texto del TextFormField
//                       String url = context.read<EntrepriseBloc>().method +
//                           context
//                               .read<EntrepriseBloc>()
//                               .entrepriceController
//                               .text
//                               .trim();
//                       // Aquí puedes utilizar la URL completa para hacer la solicitud
//                       print(url); // Debug: muestra la URL en consola
//                       context
//                           .read<EntrepriseBloc>()
//                           .add(EntrepriseButtonPressed(url));
//                     }
//                   } catch (e) {
//                     Navigator.of(context).pop();
//                     showModalDialog(context, 'Error al procesar la solicitud');
//                   }
//                 },
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
//                   child: BlocBuilder<EntrepriseBloc, EntrepriseState>(
//                     builder: (context, state) {
//                       if (state is EntrepriseLoading) {
//                         return const Center(
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                           ),
//                         );
//                       }
//                       return const Text(
//                         "Consultar",
//                         style: TextStyle(color: Colors.white),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               gapH40,
//               //temporizador
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously, must_be_immutable, avoid_print

import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/bloc/entreprise_bloc.dart';
import 'package:wms_app/src/presentation/views/global/login/widgets/list_database.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/message_modal.dart';

class SelectEnterpricePage extends StatelessWidget {
  const SelectEnterpricePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EntrepriseBloc, EntrepriseState>(
      listener: (context, state) {
        //estado de error
        if (state is EntrepriseFailure) {
          showModalDialog(context, state.error);
        }

        if (state is EntrepriseSuccess) {
          showModalBottomSheet(
              context: context,
              builder: (c) => DetailClientSale(
                    listDB: context.read<EntrepriseBloc>().entrepriceList,
                  ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [primaryColorApp, secondary, primaryColorApp])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const WarningWidgetCubit(),
                const SizedBox(
                  height: 80,
                ),
                const Padding(
                  padding: EdgeInsets.all(55),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                        "Bienvenido a WMS",
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text("Version: 1.0.0",
                            style: TextStyle(
                                color: Colors.white, fontSize: 10)),
                      )
                      //FadeIn(duration: const  Duration(microseconds: 3), child: const Text("Bienvenido a BEXMovil Provigas", style: TextStyle(color: Colors.white, fontSize: 18),)),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                    child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.only( left: 30, right: 30),
                          child: _loginForm()),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// ignore: camel_case_types
class _loginForm extends StatelessWidget {
  _loginForm();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: Image.asset(
                'assets/images/logo.jpeg',
                width: 250,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ),
          FadeIn(
              duration: const Duration(microseconds: 3),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          color: primaryColorApp.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ]),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        autocorrect: false,
                        controller:
                            context.read<EntrepriseBloc>().entrepriceController,
                        decoration: const InputDecoration(
                            disabledBorder: OutlineInputBorder(),
                            hintText: "Ingrese la url",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none),
                        onChanged: (value) {
                          context
                              .read<EntrepriseBloc>()
                              .entrepriceController
                              .text = value;
                        },
                        validator: ((value) =>
                            Validator.isEmpty(value, context)),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: primaryColorApp,
              onPressed: () async {
                FocusScope.of(context).unfocus();

                if (!_formkey.currentState!.validate()) return;

                try {
                  final result = await InternetAddress.lookup('example.com');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    context
                        .read<EntrepriseBloc>()
                        .add(EntrepriseButtonPressed());
                  }
                } catch (e) {
                  showModalDialog(context, 'Error al procesar la solicitud');
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: BlocBuilder<EntrepriseBloc, EntrepriseState>(
                  builder: (context, state) {
                    if (state is EntrepriseLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }
                    return const Text(
                      "Consultar",
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
              ))
        ],
      ),
    );
  }
}
