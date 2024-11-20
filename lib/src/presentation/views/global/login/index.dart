// ignore_for_file: use_build_context_synchronously, unused_element, unnecessary_null_comparison, avoid_print, must_be_immutable

import 'dart:io';

import 'package:wms_app/environment/environment.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/global/login/bloc/login_bloc.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/constans/gaps.dart';
import 'package:wms_app/src/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/message_modal.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.pushNamed(context, 'home');
        }

        if (state is LoginFailure) {
          showModalDialog(context, state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration:  BoxDecoration(
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                        "Bienvenido a ${ Environment.flavor.appName ?? 'WMS'} ",
                        style: const TextStyle(color: Colors.white, fontSize: 22),
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
                    padding: const EdgeInsets.only(top: 15),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                    child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, ),
                          child: BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              return _LoginForm();
                            },
                          )),
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

class _LoginForm extends StatelessWidget {
  _LoginForm({
    super.key,
  });

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Form(
          key: formkey,
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
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: primaryColorApp.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ]),
                child: Column(
                  children: [
                    TextFormField(
                        controller: context.read<LoginBloc>().email,
                        decoration:  InputDecoration(
                            disabledBorder: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.email,
                              size: 20,
                              color: primaryColorApp,
                            ),
                            hintText: "Correo electronico",
                            hintStyle:
                                const TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                            errorStyle:
                                const TextStyle(color: Colors.red, fontSize: 12)),
                        validator: (value) => Validator.email(value, context)),
                    TextFormField(
                      controller: context.read<LoginBloc>().password,
                      autocorrect: false,
                      decoration:  InputDecoration(
                          disabledBorder: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.all(10),
                          prefixIcon: Icon(
                            Icons.lock,
                            size: 20,
                            color: primaryColorApp,
                          ),
                          hintText: "Contraseña",
                          errorStyle:
                              const TextStyle(color: Colors.red, fontSize: 12),
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none),
                      validator: (value) => Validator.password(value, context),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
              gapH20,
              MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey,
                  elevation: 0,
                  color: primaryColorApp,
                  onPressed: () async {
                    //cerramos el teclado
                    FocusScope.of(context).unfocus();

                    if (!formkey.currentState!.validate()) return;

                    try {
                      final result =
                          await InternetAddress.lookup('example.com');
                      if (result.isNotEmpty &&
                          result[0].rawAddress.isNotEmpty) {
                        context
                            .read<LoginBloc>()
                            .add(LoginButtonPressed(context));
                      }
                    } catch (e, s) {
                      print("Error en login: $e $s");
                      Navigator.of(context).pop();
                      showModalDialog(context, 'No tiene conexión a internet');
                    }
                  },
                  child: Container(
                    width: size.width * 0.9,
                    height: 50,
                    alignment: Alignment.center,
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        if (state is LoginLoading) {
                          return const Center(
                            child: Text(
                              "Cargando...",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return const Text(
                          "Iniciar Sesión",
                          style: TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  )),
              const SizedBox(height: 10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    minimumSize: Size(size.width * 0.9, 40),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, 'enterprice');
                  },
                  child: Container(
                    width: 220,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      "Atras",
                      style: TextStyle(color: Colors.white),
                    ),
                  ))
            ],
          ),
        );
      },
    );
  }
}
