import 'dart:convert';

class UserModelResponse {
  final String? jsonrpc;
  final dynamic id;
  final ResultDataUser? result;

  UserModelResponse({
    this.jsonrpc,
    this.id,
    this.result,
  });

  factory UserModelResponse.fromJson(String str) =>
      UserModelResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserModelResponse.fromMap(Map<String, dynamic> json) =>
      UserModelResponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null
            ? null
            : ResultDataUser.fromMap(json["result"]),
      );

  Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
      };
}

class ResultDataUser {
  final int? uid;
  final String? name;
  final String? username;
  final String? db;
  final String? serverVersion;
  final String? webBaseUrl;

  ResultDataUser({
    this.uid,
    this.db,
    this.serverVersion,
    this.name,
    this.username,
    this.webBaseUrl,
  });

  factory ResultDataUser.fromJson(String str) =>
      ResultDataUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResultDataUser.fromMap(Map<String, dynamic> json) => ResultDataUser(
        uid: json["uid"],
        db: json["db"],
        name: json["name"],
        username: json["username"],
        webBaseUrl: json["web.base.url"],
      );

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "db": db,
        "server_version": serverVersion,
        "name": name,
        "username": username,
        "web.base.url": webBaseUrl,
      };
}
