// ignore_for_file: avoid_print, unnecessary_null_comparison, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:wms_app/src/utils/constans/colors.dart';

import 'package:flutter/material.dart';

class HttpResponseHandler {
  final BuildContext context;

  HttpResponseHandler(this.context);

  Future handleHttpResponse(Future<Response> httpCall) async {
    var response = await httpCall;
    print('handleHttpResponse: ${response.statusCode}');
    switch (response.statusCode) {
      case 200:
        return response;
      case 201:
        return response;
      case 204:
        return response;
      case 400:
        _handle400(response);
        return response;
      case 401:
        Navigator.of(context).pushNamed('/enterprice');
        // throw UnauthorizedException(response.body);

      case 422:
        _handle422(response);
        return response;
      case 440:
        // throw UnauthorizedException(response.body);
      default:
        var message = jsonDecode(response.body)["message"];
        _showErrorSnackBar([message]);
    }
  }

  _handle422(Response response) {
    // var message = jsonDecode(response.body)["message"];
    Map<String, dynamic> errors = jsonDecode(response.body)["errors"];
    var errorList = <String>[];

    var t = errors.values.map((e) => e as List<dynamic>);
    for (var element in t) {
      for (var e in element) {
        errorList.add(e as String);
      }
    }
    _showErrorSnackBar(errorList);
  }

  _handle400(Response response) {
    var message = jsonDecode(response.body)["data"];
    print('handle400: $message');
    _showErrorSnackBar([message]);
  }

  void _showErrorSnackBar(List<String> errorList) {
    final snackBar = SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: errorList.map((error) => Text(error)).toList(),
      ),
      backgroundColor: primaryColorApp,
      behavior: SnackBarBehavior.floating,
    );
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
