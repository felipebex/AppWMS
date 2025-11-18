import 'dart:convert';

class SendImgProduct {
    final String? msg;
    final int? code;
    final String? result;
    final int? productId;
    final String? productName;
    final String? productCode;
    final bool? imageProcessed;
    final String? filename;
    final int? imageSize;
    final String? imageUrl;
    final String? jsonUrl;

    SendImgProduct({
        this.msg,
        this.code,
        this.result,
        this.productId,
        this.productName,
        this.productCode,
        this.imageProcessed,
        this.filename,
        this.imageSize,
        this.imageUrl,
        this.jsonUrl,
    });

    factory SendImgProduct.fromJson(String str) => SendImgProduct.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory SendImgProduct.fromMap(Map<String, dynamic> json) => SendImgProduct(
        code: json["code"],
        msg: json["msg"],
        result: json["result"],
        productId: json["product_id"],
        productName: json["product_name"],
        productCode: json["product_code"],
        imageProcessed: json["image_processed"],
        filename: json["filename"],
        imageSize: json["image_size"],
        imageUrl: json["image_url"],
        jsonUrl: json["json_url"],
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "msg": msg,
        "result": result,
        "product_id": productId,
        "product_name": productName,
        "product_code": productCode,
        "image_processed": imageProcessed,
        "filename": filename,
        "image_size": imageSize,
        "image_url": imageUrl,
        "json_url": jsonUrl,
    };
}
