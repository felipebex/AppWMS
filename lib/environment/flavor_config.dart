// lib/environment/flavor_config.dart

enum FlavorType {
  bexpicking,
  onpoint,
}

class FlavorConfig {
  final FlavorType flavorType;
  final String appName; // This is only for in-app use
  final String appIconPath; // This is only for in-app use
  final String remoteServer;

  const FlavorConfig({
    required this.flavorType,
    required this.appName, // This is only for in-app use
    required this.appIconPath, // This is only for in-app use
    required this.remoteServer,
  });
}