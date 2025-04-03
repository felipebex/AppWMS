// To parse this JSON data, do
//
//     final enterprice = enterpriceFromMap(jsonString);

import 'dart:convert';

Enterprice enterpriceFromMap(String str) => Enterprice.fromMap(json.decode(str));

String enterpriceToMap(Enterprice data) => json.encode(data.toMap());

class Enterprice {
    String? jsonrpc;
    dynamic id;
    List<String>? result;

    Enterprice({
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory Enterprice.fromMap(Map<String, dynamic> json) => Enterprice(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? [] : List<String>.from(json["result"]!.map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x)),
    };
}
