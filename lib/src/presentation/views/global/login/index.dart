// ignore_for_file: use_build_context_synchronously, unused_element, unnecessary_null_comparison, avoid_print, must_be_immutable

import 'dart:io';

import 'package:animate_do/animate_do.dart';
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
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [primaryColorApp, secondary, primaryColorApp])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.all(55),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: FadeIn(
                              duration: const Duration(microseconds: 3),
                              child: const Text(
                                "Bienvenido a WMS",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 22),
                              ))),
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
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                    child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(30),
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
                  'assets/images/icon.png',
                  width: 300,
                  height: 200,
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
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                              controller: context.read<LoginBloc>().email,
                              decoration: const InputDecoration(
                                  disabledBorder: OutlineInputBorder(),
                                  hintText: "Correo electronico",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none),
                              onChanged: (value) {
                                context.read<LoginBloc>().email.text = value;
                              },
                              validator: (value) =>
                                  Validator.email(value, context)),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            controller: context.read<LoginBloc>().password,
                            autocorrect: false,
                            decoration: const InputDecoration(
                                disabledBorder: OutlineInputBorder(),
                                hintText: "Contraseña",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none),
                            onChanged: (value) =>
                                context.read<LoginBloc>().password.text = value,
                            validator: (value) =>
                                Validator.password(value, context),
                          ),
                        ),
                      ],
                    ),
                  )),
              gapH40,
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
                        context.read<LoginBloc>().add(LoginButtonPressed());

                        // final bool response = await authService.loginUser(
                        //     loginForm.email, loginForm.password);

                        // if (response) {
                        //   loginForm.isLoading = false;
                        //   Navigator.pushNamed(context, 'drawer');
                        // } else {
                        //   loginForm.isLoading = false;

                        //   final snackBar = SnackBar(
                        //     content: const Text(
                        //         "Datos incorrectos, intente nuevamente"),
                        //     action: SnackBarAction(
                        //       textColor: primaryColorApp,
                        //       label: 'Cerrar',
                        //       onPressed: () {
                        //         const CloseButton();
                        //       },
                        //     ),
                        //   );

                        //   ScaffoldMessenger.of(context)
                        //       .showSnackBar(snackBar);
                        // }
                      }
                    } catch (e, s) {
                      print("Error en login: $e $s");
                      Navigator.of(context).pop();
                      showModalDialog(context, 'No tiene conexión a internet');
                    }
                  },
                  child: Container(
                    width: 220,
                    height: 50,
                    alignment: Alignment.center,
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        if (state is LoginLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
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
              MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey,
                  elevation: 0,
                  color: grey,
                  onPressed: () {
                    // context.read<EntrepriseBloc>().add(LoadUrlFromDB());
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
