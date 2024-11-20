// lib/main_narnia.dart

import 'environment/environment.dart';
import 'environment/flavor_config.dart';
import 'main.dart' as common;

void main() {
  Environment.flavor = const FlavorConfig(
    flavorType: FlavorType.onpoint,
    appName: 'On Point',
    appIconPath: 'assets/icons/icon360.png',
    remoteServer: 'x.x.x.x:port',
  );

  common.main();
}