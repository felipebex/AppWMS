// ignore_for_file: avoid_print, depend_on_referenced_packages, unnecessary_null_comparison, unnecessary_import

import 'package:wms_app/src/presentation/views/global/login/data/login_api_module.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  LoginBloc() : super(LoginInitial()) {

    on<LoginButtonPressed>((event, emit) async {
      try {
        emit(LoginLoading());
        final session = await LoginApiModule.loginUser(
          email.text,
          password.text,
          event.context,
        );
        if (session) {
          email.clear();
          password.clear();
          emit(LoginSuccess());
          //limpiamos los campos
        } else {
          emit(LoginFailure('Autenticación fallida.'));
        }
      } catch (e, s) {
        print('Error en login_bloc.dart: $e $s');
        emit(LoginFailure('Error en login_bloc.dart: $e $s'));
      }
    });
  }
}
