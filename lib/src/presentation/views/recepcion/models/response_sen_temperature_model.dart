import 'dart:convert';

class TemperatureSend {
    final int? code;
    final String? msg;
    final String? result;
    final int? lineId;
    final double? temperature;
    final String? filename;
    final int? imageSize;
    final String? imageUrl;
    final String? jsonUrl;
    final String? productName;

    TemperatureSend({
        this.code,
        this.msg,
        this.result,
        this.lineId,
        this.temperature,
        this.filename,
        this.imageSize,
        this.imageUrl,
        this.jsonUrl,
        this.productName,
    });

    factory TemperatureSend.fromJson(String str) => TemperatureSend.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory TemperatureSend.fromMap(Map<String, dynamic> json) => TemperatureSend(
        code: json["code"],
        msg: json["msg"],
        result: json["result"],
        lineId: json["line_id"],
        temperature: json["temperature"]?.toDouble(),
        filename: json["filename"],
        imageSize: json["image_size"],
        imageUrl: json["image_url"],
        jsonUrl: json["json_url"],
        productName: json["product_name"],
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
        "result": result,
        "line_id": lineId,
        "temperature": temperature,
        "filename": filename,
        "image_size": imageSize,
        "image_url": imageUrl,
        "json_url": jsonUrl,
        "product_name": productName,
    };
}
