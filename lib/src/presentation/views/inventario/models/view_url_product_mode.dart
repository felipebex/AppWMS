import 'dart:convert';

class ViewUrlImgProduct {
    final String? jsonrpc;
    final dynamic id;
    final ViewUrlImgProductResult? result;

    ViewUrlImgProduct({
          
        this.jsonrpc,
        this.id,
        this.result,
    });

    factory ViewUrlImgProduct.fromJson(String str) => ViewUrlImgProduct.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ViewUrlImgProduct.fromMap(Map<String, dynamic> json) => ViewUrlImgProduct(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : ViewUrlImgProductResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class ViewUrlImgProductResult {
    final String? msg;
    final int? code;
    final ResultResult? result;

    ViewUrlImgProductResult({
        this.msg,
        this.code,
        this.result,
    });

    factory ViewUrlImgProductResult.fromJson(String str) => ViewUrlImgProductResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ViewUrlImgProductResult.fromMap(Map<String, dynamic> json) => ViewUrlImgProductResult(
        msg: json["msg"],
        code: json["code"],
        result: json["result"] == null ? null : ResultResult.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "msg": msg,
        "code": code,
        "result": result?.toMap(),
    };
}

class ResultResult {
    final String? url;

    ResultResult({
        this.url,
    });

    factory ResultResult.fromJson(String str) => ResultResult.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResultResult.fromMap(Map<String, dynamic> json) => ResultResult(
        url: json["url"],
    );

    Map<String, dynamic> toMap() => {
        "url": url,
    };
}
