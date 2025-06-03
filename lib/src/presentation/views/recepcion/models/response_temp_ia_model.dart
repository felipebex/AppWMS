import 'dart:convert';

class TemperatureIa {
    final double? temperature;
    final String? unit;
    final String? confidence;
    final String? detail;

    TemperatureIa({
        this.temperature,
        this.unit,
        this.confidence,
        this.detail,
    });

    factory TemperatureIa.fromJson(String str) => TemperatureIa.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory TemperatureIa.fromMap(Map<String, dynamic> json) => TemperatureIa(
        temperature: json["temperature"]?.toDouble(),
        unit: json["unit"],
        confidence: json["confidence"],
        detail: json["detail"],
    );

    Map<String, dynamic> toMap() => {
        "temperature": temperature,
        "unit": unit,
        "confidence": confidence,
        "detail": detail,
    };
}
