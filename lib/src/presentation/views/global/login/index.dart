// ignore_for_file: use_build_context_synchronously, unused_element, unnecessary_null_comparison, avoid_print, must_be_immutable, prefer_final_fields

import 'dart:io';

import 'package:get/get.dart';
import 'package:wms_app/src/presentation/providers/network/cubit/warning_widget_cubit.dart';
import 'package:wms_app/src/presentation/views/global/login/bloc/login_bloc.dart';
import 'package:wms_app/src/presentation/views/inventario/screens/bloc/inventario_bloc.dart';
import 'package:wms_app/src/presentation/views/recepcion/modules/individual/screens/bloc/recepcion_bloc.dart';
import 'package:wms_app/src/presentation/views/transferencias/transfer-interna/bloc/transferencia_bloc.dart';
import 'package:wms_app/src/presentation/views/user/screens/bloc/user_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_packing/presentation/packing-batch/bloc/wms_packing_bloc.dart';
import 'package:wms_app/src/presentation/views/wms_picking/bloc/wms_picking_bloc.dart';
import 'package:wms_app/src/presentation/widgets/keyboard_widget.dart';
import 'package:wms_app/src/utils/constans/colors.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/src/utils/widgets/dialog_loading.dart';

import '../../../widgets/message_modal.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              print('STATE LOGIN: $state');
              if (state is LoginLoading) {
                Get.dialog(
                  DialogLoadingNetwork(
                    titel: 'Login',
                  ),
                  barrierDismissible:
                      false, // No permitir cerrar tocando fuera del diálogo
                );
              }
              if (state is LoginSuccess) {
                context.read<UserBloc>().add(RegisterDeviceIdEvent());
              }

              if (state is LoginFailure) {
                Get.back();
                showModalDialog(context, state.error);
              }
            },
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) async {
              print('STATE USER: $state');

              if (state is RegisterDeviceIdError) {
                Get.back();
                showModalDialog(context, state.message);
              }

              if (state is RegisterDeviceIdSuccess) {
                context.read<UserBloc>().add(
                    GetConfigurations(context)); //configuracion del usuario
              }

              if (state is ConfigurationLoaded) {
                context
                    .read<WMSPickingBloc>()
                    .add(LoadAllNovedades(context)); //novedades
                context
                    .read<UserBloc>()
                    .add(GetUbicacionesEvent()); //ubicaciones
                context
                    .read<InventarioBloc>()
                    .add(GetProductsEvent(isDialogLoading: true));

                context.read<LoginBloc>().email.clear();
                context.read<LoginBloc>().password.clear();
                Get.back();
                Navigator.pushReplacementNamed(context, '/home');
              }

              if (state is ConfigurationError) {
                Get.back();
                showModalDialog(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Scaffold(
                body: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          colors: [
                        primaryColorApp,
                        secondary,
                        primaryColorApp
                      ])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const WarningWidgetCubit(),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15, left: 20, right: 20, bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: Text(
                              "Bienvenido a OnPoint",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 22),
                            )),

                            Center(
                              child: Text(
                                  "Version: ${context.read<UserBloc>().versionApp}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
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
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40))),
                          child: SingleChildScrollView(
                            child: BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                return const _LoginForm();
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    super.key,
  });

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  FocusNode _focusNodeEmail = FocusNode();
  FocusNode _focusNodePassword = FocusNode();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    // No olvides liberar los FocusNode al finalizar el formulario
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Establecer el controlador según el foco activo
    TextEditingController activeController = _focusNodeEmail.hasFocus
        ? context.read<LoginBloc>().email
        : context.read<LoginBloc>().password;

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Form(
          key: formkey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 30, right: 30),
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
                      focusNode: _focusNodeEmail,
                      controller: context.read<LoginBloc>().email,
                      onTap:
                          !context.read<UserBloc>().fabricante.contains("Zebra")
                              ? null
                              : () {
                                  setState(() {
                                    FocusScope.of(context).requestFocus(
                                        _focusNodeEmail); // Solicitar foco inmediatamente
                                  });
                                },
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        disabledBorder: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.email,
                          size: 15,
                          color: primaryColorApp,
                        ),
                        hintText: "Correo electrónico",
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(10),
                        errorStyle:
                            const TextStyle(color: Colors.red, fontSize: 10),
                      ),
                      validator: (value) => Validator.email(value, context),
                    ),
                    TextFormField(
                      controller: context.read<LoginBloc>().password,
                      autocorrect: false,
                      obscureText: context.watch<LoginBloc>().isVisible,
                      focusNode: _focusNodePassword,
                      style: const TextStyle(fontSize: 13),
                      onTap:
                          !context.read<UserBloc>().fabricante.contains("Zebra")
                              ? null
                              : () {
                                  setState(() {
                                    FocusScope.of(context).requestFocus(
                                        _focusNodePassword); // Solicitar foco inmediatamente
                                  });
                                },
                      decoration: InputDecoration(
                        disabledBorder: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(10),
                        prefixIcon: Icon(
                          Icons.lock,
                          size: 15,
                          color: primaryColorApp,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            context
                                .read<LoginBloc>()
                                .add(TogglePasswordVisibility());
                          },
                          icon: Icon(
                            context.watch<LoginBloc>().isVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 15,
                            color: primaryColorApp,
                          ),
                        ),
                        hintText: "Contraseña",
                        errorStyle:
                            const TextStyle(color: Colors.red, fontSize: 10),
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      validator: (value) => Validator.password(value, context),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledColor: Colors.grey,
                    elevation: 0,
                    color: primaryColorApp,
                    onPressed: () async {
                      if (!context
                          .read<UserBloc>()
                          .fabricante
                          .contains("Zebra")) {
                        FocusScope.of(context).unfocus();
                      }
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
                        showModalDialog(
                            context, 'No tiene conexión a internet');
                      }
                    },
                    child: Container(
                      width: size.width * 0.9,
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                      minimumSize: Size(size.width * 0.9, 20),
                    ),
                    onPressed: () {
                      // Limpiamos los campos
                      // context.read<LoginBloc>().email.clear();
                      context.read<LoginBloc>().password.clear();
                      Navigator.pushReplacementNamed(context, 'enterprice');
                    },
                    child: Container(
                      width: 220,
                      height: 30,
                      alignment: Alignment.center,
                      child: const Text(
                        "Atras",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              Visibility(
                visible: context.read<UserBloc>().fabricante.contains("Zebra"),
                child: CustomKeyboard(
                    isLogin: true,
                    controller:
                        activeController, // Cambia el controlador activamente
                    onchanged: () {}),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
