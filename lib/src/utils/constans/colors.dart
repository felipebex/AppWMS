import 'package:flutter/material.dart';
import 'package:wms_app/environment/environment.dart';

const Color primary = Color.fromARGB(255, 235, 238, 240);
const Color primaryListBuilder = Color.fromARGB(255, 214, 209, 209);
const Color secondary = Color(0xFFdbe4f3);

const Color white = Color(0xFFFFFFFF);
const Color grey = Colors.grey;
const Color lightGrey = Color.fromARGB(255, 200, 198, 198);
const Color black = Colors.black54;
const Color red = Color.fromARGB(255, 237, 78, 78);

const Color green = Color(0xFF43aa8b);
const Color yellow = Color(0xFFf7b731);
const Color blue = Color(0xFF28c2ff);
const Color buttoncolor =
// 4e77ed
    Color.fromARGB(255, 78, 119, 237);
const Color mainFontColor = Color.fromARGB(255, 78, 119, 237);

const Color arrowbgColor = Color(0xffe4e9f7);
Color primaryColorApp = Environment.flavor.appName == 'BexPicking'
    ? const Color.fromARGB(255, 237, 131, 78)
    : const Color.fromARGB(255, 19, 46, 129);

Color primaryColorAppLigth = Environment.flavor.appName == 'BexPicking'
    ? const Color.fromARGB(255, 250, 212, 186)
    : const Color.fromARGB(255, 186, 202, 250);

//color de acciones

const Color colorAction = Color.fromARGB(255, 117, 175, 51);
const Color colorActionCancel = Color.fromARGB(255, 255, 0, 0);
const Color colorActionDefault = Color.fromARGB(255, 247, 189, 15);
