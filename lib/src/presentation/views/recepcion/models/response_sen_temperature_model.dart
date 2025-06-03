import 'dart:convert';

class TemperatureSend {
    final int? code;
    final String? result;
    final int? lineId;
    final String? msg;

    TemperatureSend({
        this.code,
        this.result,
        this.lineId,
        this.msg,
    });

    factory TemperatureSend.fromJson(String str) => TemperatureSend.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory TemperatureSend.fromMap(Map<String, dynamic> json) => TemperatureSend(
        code: json["code"],
        result: json["result"],
        lineId: json["line_id"],
        msg: json["msg"],
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result,
        "line_id": lineId,
        "msg": msg,
    };
}
