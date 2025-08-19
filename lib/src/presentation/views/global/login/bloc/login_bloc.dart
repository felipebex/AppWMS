// ignore_for_file: avoid_print, depend_on_referenced_packages, unnecessary_null_comparison, unnecessary_import


import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wms_app/src/core/utils/prefs/pref_utils.dart';
import 'package:wms_app/src/presentation/views/global/login/data/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();



   bool isVisible = false;

  LoginRepository loginRepository = LoginRepository();

  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      try {
        emit(LoginLoading());

        final response = await loginRepository.login(email.text, password.text, );
        print("Response: $response");
        if (response.result == null) {
          emit(LoginFailure('Autenticación fallida.'));
        } else {
          PrefUtils.setUserName(response.result?.name?? 'No-name');
          PrefUtils.setUserEmail(response.result?.username?? 'No-email');
          PrefUtils.setUserPass(password.text);
          PrefUtils.setUserId(response.result?.uid?? 0);
          emit(LoginSuccess());
        }
      
      } catch (e, s) {
        print('Error en login_bloc.dart: $e $s');
        emit(LoginFailure('Error en login_bloc.dart: $e $s'));
      }
    });

     on<TogglePasswordVisibility>((event, emit) {
      isVisible = !isVisible;
      emit(PasswordVisibilityToggled(isVisible));
    });
  }
}
