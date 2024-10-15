// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';

class Log {
  Log(var value) {
    if (!kReleaseMode) {
      print("===============> ${value.toString()} <=====================");
    }
  }
}
