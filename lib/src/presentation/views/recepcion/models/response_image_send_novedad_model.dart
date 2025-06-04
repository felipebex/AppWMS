import 'dart:convert';

class ImageSendNovedad {
    final int? code;
    final String? result;
    final int? stockMoveId;
    final int? stockMoveLineId;
    final String? imageUrl;
    final String? filename;
    final String? msg;

    ImageSendNovedad({
        this.code,
        this.result,
        this.stockMoveId,
        this.stockMoveLineId,
        this.imageUrl,
        this.filename,
        this.msg,
    });

    factory ImageSendNovedad.fromJson(String str) => ImageSendNovedad.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ImageSendNovedad.fromMap(Map<String, dynamic> json) => ImageSendNovedad(
        code: json["code"],
        result: json["result"],
        stockMoveId: json["stock_move_id"],
        stockMoveLineId: json["stock_move_line_id"],
        imageUrl: json["image_url"],
        filename: json["filename"],
        msg: json["msg"],
    );

    Map<String, dynamic> toMap() => {
        "code": code,
        "result": result,
        "stock_move_id": stockMoveId,
        "stock_move_line_id": stockMoveLineId,
        "image_url": imageUrl,
        "filename": filename,
        "msg": msg,
    };
}
