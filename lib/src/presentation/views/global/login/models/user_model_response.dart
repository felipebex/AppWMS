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
  final bool? isSystem;
  final bool? isAdmin;
  final bool? isPublic;
  final bool? isInternalUser;

  final String? db;

  final UserSettings? userSettings;

  final String? serverVersion;
  final List<dynamic>? serverVersionInfo;

  final String? partnerDisplayName;

  final int? partnerId;
  final String? webBaseUrl;

  final List<int>? userId;

  ResultDataUser({
    this.uid,
    this.isSystem,
    this.isAdmin,
    this.isPublic,
    this.isInternalUser,
    this.db,
    this.userSettings,
    this.serverVersion,
    this.serverVersionInfo,
    this.name,
    this.username,
    this.partnerDisplayName,
    this.partnerId,
    this.webBaseUrl,
    this.userId,
  });

  factory ResultDataUser.fromJson(String str) =>
      ResultDataUser.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ResultDataUser.fromMap(Map<String, dynamic> json) => ResultDataUser(
        uid: json["uid"],
        isSystem: json["is_system"],
        isAdmin: json["is_admin"],
        isPublic: json["is_public"],
        isInternalUser: json["is_internal_user"],
        db: json["db"],
        userSettings: json["user_settings"] == null
            ? null
            : UserSettings.fromMap(json["user_settings"]),
        serverVersion: json["server_version"],
        serverVersionInfo: json["server_version_info"] == null
            ? []
            : List<dynamic>.from(json["server_version_info"]!.map((x) => x)),
        name: json["name"],
        username: json["username"],
        partnerDisplayName: json["partner_display_name"],
        partnerId: json["partner_id"],
        webBaseUrl: json["web.base.url"],
        userId: json["user_id"] == null
            ? []
            : List<int>.from(json["user_id"]!.map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "is_system": isSystem,
        "is_admin": isAdmin,
        "is_public": isPublic,
        "is_internal_user": isInternalUser,
        "db": db,
        "user_settings": userSettings?.toMap(),
        "server_version": serverVersion,
        "server_version_info": serverVersionInfo == null
            ? []
            : List<dynamic>.from(serverVersionInfo!.map((x) => x)),
        "name": name,
        "username": username,
        "partner_display_name": partnerDisplayName,
        "partner_id": partnerId,
        "web.base.url": webBaseUrl,
        "user_id":
            userId == null ? [] : List<dynamic>.from(userId!.map((x) => x)),
      };
}

class UserSettings {
  final int? id;
  final UserId? userId;

  UserSettings({
    this.id,
    this.userId,
  });

  factory UserSettings.fromJson(String str) =>
      UserSettings.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserSettings.fromMap(Map<String, dynamic> json) => UserSettings(
        id: json["id"],
        userId:
            json["user_id"] == null ? null : UserId.fromMap(json["user_id"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userId?.toMap(),
      };
}

class UserId {
  final dynamic? id;

  UserId({
    this.id,
  });

  factory UserId.fromJson(String str) => UserId.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserId.fromMap(Map<String, dynamic> json) => UserId(
        id: json["id"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
      };
}
