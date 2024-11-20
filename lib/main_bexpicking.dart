
import 'environment/environment.dart';
import 'environment/flavor_config.dart';
import 'main.dart' as common;

void main() {
  Environment.flavor = const FlavorConfig(
    flavorType: FlavorType.bexpicking,
    appName: 'BexPicking',
    appIconPath: 'assets/icons/iconBeX.png',
    remoteServer: 'x.x.x.x:port',
  );

  common.main();
}