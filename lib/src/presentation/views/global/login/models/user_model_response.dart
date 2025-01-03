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

    factory UserModelResponse.fromJson(String str) => UserModelResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UserModelResponse.fromMap(Map<String, dynamic> json) => UserModelResponse(
        jsonrpc: json["jsonrpc"],
        id: json["id"],
        result: json["result"] == null ? null : ResultDataUser.fromMap(json["result"]),
    );

    Map<String, dynamic> toMap() => {
        "jsonrpc": jsonrpc,
        "id": id,
        "result": result?.toMap(),
    };
}

class ResultDataUser {
    final int? uid;
    final bool? isSystem;
    final bool? isAdmin;
    final bool? isPublic;
    final bool? isInternalUser;
    final UserContext? userContext;
    final String? db;
    final UserSettings? userSettings;
    final String? serverVersion;
    final List<dynamic>? serverVersionInfo;
    final String? supportUrl;
    final String? name;
    final String? username;
    final String? partnerDisplayName;
    final int? partnerId;
    final String? webBaseUrl;
    final int? activeIdsLimit;
    final dynamic profileSession;
    final dynamic profileCollectors;
    final dynamic profileParams;
    final int? maxFileUploadSize;
    final bool? homeActionId;
    final CacheHashes? cacheHashes;
    final Map<String, Currency>? currencies;
    final BundleParams? bundleParams;
    final UserCompanies? userCompanies;
    final bool? showEffect;
    final bool? displaySwitchCompanyMenu;
    final List<int>? userId;
    final int? maxTimeBetweenKeysInMs;
    final String? websocketWorkerVersion;
    final List<dynamic>? webTours;
    final bool? tourDisable;
    final String? notificationType;
    final bool? odoobotInitialized;
    final bool? iapCompanyEnrich;
    final String? isQuickEditModeEnabled;

    ResultDataUser({
        this.uid,
        this.isSystem,
        this.isAdmin,
        this.isPublic,
        this.isInternalUser,
        this.userContext,
        this.db,
        this.userSettings,
        this.serverVersion,
        this.serverVersionInfo,
        this.supportUrl,
        this.name,
        this.username,
        this.partnerDisplayName,
        this.partnerId,
        this.webBaseUrl,
        this.activeIdsLimit,
        this.profileSession,
        this.profileCollectors,
        this.profileParams,
        this.maxFileUploadSize,
        this.homeActionId,
        this.cacheHashes,
        this.currencies,
        this.bundleParams,
        this.userCompanies,
        this.showEffect,
        this.displaySwitchCompanyMenu,
        this.userId,
        this.maxTimeBetweenKeysInMs,
        this.websocketWorkerVersion,
        this.webTours,
        this.tourDisable,
        this.notificationType,
        this.odoobotInitialized,
        this.iapCompanyEnrich,
        this.isQuickEditModeEnabled,
    });

    factory ResultDataUser.fromJson(String str) => ResultDataUser.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ResultDataUser.fromMap(Map<String, dynamic> json) => ResultDataUser(
        uid: json["uid"],
        isSystem: json["is_system"],
        isAdmin: json["is_admin"],
        isPublic: json["is_public"],
        isInternalUser: json["is_internal_user"],
        userContext: json["user_context"] == null ? null : UserContext.fromMap(json["user_context"]),
        db: json["db"],
        userSettings: json["user_settings"] == null ? null : UserSettings.fromMap(json["user_settings"]),
        serverVersion: json["server_version"],
        serverVersionInfo: json["server_version_info"] == null ? [] : List<dynamic>.from(json["server_version_info"]!.map((x) => x)),
        supportUrl: json["support_url"],
        name: json["name"],
        username: json["username"],
        partnerDisplayName: json["partner_display_name"],
        partnerId: json["partner_id"],
        webBaseUrl: json["web.base.url"],
        activeIdsLimit: json["active_ids_limit"],
        profileSession: json["profile_session"],
        profileCollectors: json["profile_collectors"],
        profileParams: json["profile_params"],
        maxFileUploadSize: json["max_file_upload_size"],
        homeActionId: json["home_action_id"],
        cacheHashes: json["cache_hashes"] == null ? null : CacheHashes.fromMap(json["cache_hashes"]),
        currencies: Map.from(json["currencies"]!).map((k, v) => MapEntry<String, Currency>(k, Currency.fromMap(v))),
        bundleParams: json["bundle_params"] == null ? null : BundleParams.fromMap(json["bundle_params"]),
        userCompanies: json["user_companies"] == null ? null : UserCompanies.fromMap(json["user_companies"]),
        showEffect: json["show_effect"],
        displaySwitchCompanyMenu: json["display_switch_company_menu"],
        userId: json["user_id"] == null ? [] : List<int>.from(json["user_id"]!.map((x) => x)),
        maxTimeBetweenKeysInMs: json["max_time_between_keys_in_ms"],
        websocketWorkerVersion: json["websocket_worker_version"],
        webTours: json["web_tours"] == null ? [] : List<dynamic>.from(json["web_tours"]!.map((x) => x)),
        tourDisable: json["tour_disable"],
        notificationType: json["notification_type"],
        odoobotInitialized: json["odoobot_initialized"],
        iapCompanyEnrich: json["iap_company_enrich"],
        isQuickEditModeEnabled: json["is_quick_edit_mode_enabled"],
    );

    Map<String, dynamic> toMap() => {
        "uid": uid,
        "is_system": isSystem,
        "is_admin": isAdmin,
        "is_public": isPublic,
        "is_internal_user": isInternalUser,
        "user_context": userContext?.toMap(),
        "db": db,
        "user_settings": userSettings?.toMap(),
        "server_version": serverVersion,
        "server_version_info": serverVersionInfo == null ? [] : List<dynamic>.from(serverVersionInfo!.map((x) => x)),
        "support_url": supportUrl,
        "name": name,
        "username": username,
        "partner_display_name": partnerDisplayName,
        "partner_id": partnerId,
        "web.base.url": webBaseUrl,
        "active_ids_limit": activeIdsLimit,
        "profile_session": profileSession,
        "profile_collectors": profileCollectors,
        "profile_params": profileParams,
        "max_file_upload_size": maxFileUploadSize,
        "home_action_id": homeActionId,
        "cache_hashes": cacheHashes?.toMap(),
        "currencies": Map.from(currencies!).map((k, v) => MapEntry<String, dynamic>(k, v.toMap())),
        "bundle_params": bundleParams?.toMap(),
        "user_companies": userCompanies?.toMap(),
        "show_effect": showEffect,
        "display_switch_company_menu": displaySwitchCompanyMenu,
        "user_id": userId == null ? [] : List<dynamic>.from(userId!.map((x) => x)),
        "max_time_between_keys_in_ms": maxTimeBetweenKeysInMs,
        "websocket_worker_version": websocketWorkerVersion,
        "web_tours": webTours == null ? [] : List<dynamic>.from(webTours!.map((x) => x)),
        "tour_disable": tourDisable,
        "notification_type": notificationType,
        "odoobot_initialized": odoobotInitialized,
        "iap_company_enrich": iapCompanyEnrich,
        "is_quick_edit_mode_enabled": isQuickEditModeEnabled,
    };
}

class BundleParams {
    final String? lang;

    BundleParams({
        this.lang,
    });

    factory BundleParams.fromJson(String str) => BundleParams.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory BundleParams.fromMap(Map<String, dynamic> json) => BundleParams(
        lang: json["lang"],
    );

    Map<String, dynamic> toMap() => {
        "lang": lang,
    };
}

class CacheHashes {
    final String? translations;
    final String? loadMenus;

    CacheHashes({
        this.translations,
        this.loadMenus,
    });

    factory CacheHashes.fromJson(String str) => CacheHashes.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory CacheHashes.fromMap(Map<String, dynamic> json) => CacheHashes(
        translations: json["translations"],
        loadMenus: json["load_menus"],
    );

    Map<String, dynamic> toMap() => {
        "translations": translations,
        "load_menus": loadMenus,
    };
}

class Currency {
    final String? symbol;
    final String? position;
    final List<int>? digits;

    Currency({
        this.symbol,
        this.position,
        this.digits,
    });

    factory Currency.fromJson(String str) => Currency.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Currency.fromMap(Map<String, dynamic> json) => Currency(
        symbol: json["symbol"],
        position: json["position"],
        digits: json["digits"] == null ? [] : List<int>.from(json["digits"]!.map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "symbol": symbol,
        "position": position,
        "digits": digits == null ? [] : List<dynamic>.from(digits!.map((x) => x)),
    };
}

class UserCompanies {
    final int? currentCompany;
    final AllowedCompanies? allowedCompanies;
    final DisallowedAncestorCompanies? disallowedAncestorCompanies;

    UserCompanies({
        this.currentCompany,
        this.allowedCompanies,
        this.disallowedAncestorCompanies,
    });

    factory UserCompanies.fromJson(String str) => UserCompanies.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UserCompanies.fromMap(Map<String, dynamic> json) => UserCompanies(
        currentCompany: json["current_company"],
        allowedCompanies: json["allowed_companies"] == null ? null : AllowedCompanies.fromMap(json["allowed_companies"]),
        disallowedAncestorCompanies: json["disallowed_ancestor_companies"] == null ? null : DisallowedAncestorCompanies.fromMap(json["disallowed_ancestor_companies"]),
    );

    Map<String, dynamic> toMap() => {
        "current_company": currentCompany,
        "allowed_companies": allowedCompanies?.toMap(),
        "disallowed_ancestor_companies": disallowedAncestorCompanies?.toMap(),
    };
}

class AllowedCompanies {
    final The1? the1;

    AllowedCompanies({
        this.the1,
    });

    factory AllowedCompanies.fromJson(String str) => AllowedCompanies.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory AllowedCompanies.fromMap(Map<String, dynamic> json) => AllowedCompanies(
        the1: json["1"] == null ? null : The1.fromMap(json["1"]),
    );

    Map<String, dynamic> toMap() => {
        "1": the1?.toMap(),
    };
}

class The1 {
    final int? id;
    final String? name;
    final int? sequence;
    final List<dynamic>? childIds;
    final bool? parentId;

    The1({
        this.id,
        this.name,
        this.sequence,
        this.childIds,
        this.parentId,
    });

    factory The1.fromJson(String str) => The1.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory The1.fromMap(Map<String, dynamic> json) => The1(
        id: json["id"],
        name: json["name"],
        sequence: json["sequence"],
        childIds: json["child_ids"] == null ? [] : List<dynamic>.from(json["child_ids"]!.map((x) => x)),
        parentId: json["parent_id"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "sequence": sequence,
        "child_ids": childIds == null ? [] : List<dynamic>.from(childIds!.map((x) => x)),
        "parent_id": parentId,
    };
}

class DisallowedAncestorCompanies {
    DisallowedAncestorCompanies();

    factory DisallowedAncestorCompanies.fromJson(String str) => DisallowedAncestorCompanies.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory DisallowedAncestorCompanies.fromMap(Map<String, dynamic> json) => DisallowedAncestorCompanies(
    );

    Map<String, dynamic> toMap() => {
    };
}

class UserContext {
    final String? lang;
    final String? tz;
    final int? uid;

    UserContext({
        this.lang,
        this.tz,
        this.uid,
    });

    factory UserContext.fromJson(String str) => UserContext.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UserContext.fromMap(Map<String, dynamic> json) => UserContext(
        lang: json["lang"],
        tz: json["tz"],
        uid: json["uid"],
    );

    Map<String, dynamic> toMap() => {
        "lang": lang,
        "tz": tz,
        "uid": uid,
    };
}

class UserSettings {
    final int? id;
    final UserId? userId;
    final bool? isDiscussSidebarCategoryChannelOpen;
    final bool? isDiscussSidebarCategoryChatOpen;
    final bool? pushToTalkKey;
    final bool? usePushToTalk;
    final int? voiceActiveDuration;
    final List<List<dynamic>>? volumeSettingsIds;

    UserSettings({
        this.id,
        this.userId,
        this.isDiscussSidebarCategoryChannelOpen,
        this.isDiscussSidebarCategoryChatOpen,
        this.pushToTalkKey,
        this.usePushToTalk,
        this.voiceActiveDuration,
        this.volumeSettingsIds,
    });

    factory UserSettings.fromJson(String str) => UserSettings.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory UserSettings.fromMap(Map<String, dynamic> json) => UserSettings(
        id: json["id"],
        userId: json["user_id"] == null ? null : UserId.fromMap(json["user_id"]),
        isDiscussSidebarCategoryChannelOpen: json["is_discuss_sidebar_category_channel_open"],
        isDiscussSidebarCategoryChatOpen: json["is_discuss_sidebar_category_chat_open"],
        pushToTalkKey: json["push_to_talk_key"],
        usePushToTalk: json["use_push_to_talk"],
        voiceActiveDuration: json["voice_active_duration"],
        volumeSettingsIds: json["volume_settings_ids"] == null ? [] : List<List<dynamic>>.from(json["volume_settings_ids"]!.map((x) => List<dynamic>.from(x.map((x) => x)))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userId?.toMap(),
        "is_discuss_sidebar_category_channel_open": isDiscussSidebarCategoryChannelOpen,
        "is_discuss_sidebar_category_chat_open": isDiscussSidebarCategoryChatOpen,
        "push_to_talk_key": pushToTalkKey,
        "use_push_to_talk": usePushToTalk,
        "voice_active_duration": voiceActiveDuration,
        "volume_settings_ids": volumeSettingsIds == null ? [] : List<dynamic>.from(volumeSettingsIds!.map((x) => List<dynamic>.from(x.map((x) => x)))),
    };
}

class UserId {
    final int? id;

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
