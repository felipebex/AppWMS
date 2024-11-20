import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:wms_app/environment/environment.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/global/enterprise/bloc/entreprise_bloc.dart';
import 'package:wms_app/src/presentation/views/global/login/widgets/list_database.dart';
import 'package:wms_app/src/services/notification_service.dart';
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
            decoration: BoxDecoration(
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
                Padding(
                  padding: const EdgeInsets.all(55),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                        "Bienvenido a ${Environment.flavor.appName ?? 'WMS'} ",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 22),
                      )),
                      const SizedBox(
                        height: 10,
                      ),
                      const Center(
                        child: Text("Version: 1.0.0",
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
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
                          padding: const EdgeInsets.only(left: 30, right: 30),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: Image.asset(
              Environment.flavor.appName == "BexPicking"
                  ? 'assets/icons/iconBex.png'
                  : 'assets/images/icono.jpeg',
              width: Environment.flavor.appName == "BexPicking" ? 100 : 250,
              height: 140,
              fit: BoxFit.cover,
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
              )),

        ],
      ),
    );
  }
}
