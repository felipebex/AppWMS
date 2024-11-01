// ignore_for_file: avoid_print, depend_on_referenced_packages, unnecessary_null_comparison, unnecessary_import

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/presentation/views/global/login/data/login_repository.dart';
import 'package:wms_app/src/utils/prefs/pref_utils.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  LoginRepository loginRepository = LoginRepository();

  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      try {
        emit(LoginLoading());

        final response = await loginRepository.login(email.text, password.text);
        print("Response: $response");
        if (response.data == null) {
          emit(LoginFailure('Autenticación fallida.'));
        } else {
          email.clear();
          password.clear();
          PrefUtils.setUserName(response.data?.result?.name?? 'No-name');
          PrefUtils.setUserEmail(response.data?.result?.email?? 'No-email');
          PrefUtils.setUserRol(response.data?.result?.rol?? 'No-rol');
          PrefUtils.setIsLoggedIn(true);
          emit(LoginSuccess());
        }
      
      } catch (e, s) {
        print('Error en login_bloc.dart: $e $s');
        emit(LoginFailure('Error en login_bloc.dart: $e $s'));
      }
    });
  }
}
