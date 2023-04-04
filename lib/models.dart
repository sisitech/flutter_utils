library flutter_utils;

import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

const offline_http_call_prefix = "offline_http_call";

@JsonSerializable()
class OfflineHttpCall {
  String name;
  String urlPath;
  String? instanceId;
  String storageContainer;
  dynamic formData;
  String httpMethod;
  String status = "";
  int tries = 0;

  OfflineHttpCall({
    this.formData,
    required this.name,
    required this.httpMethod,
    required this.urlPath,
    this.instanceId,
    this.storageContainer = "GetStorage",
  });

  dynamic get instance {
    var data = formData;
    if (httpMethod != "POST") {
      if (instanceId != null) {
        data["id"] = instanceId;
        return data;
      }
      var id = "api/v1/users/32/".idFromUpdateUrl;
      if (id != null) {
        data["id"] = id;
        return data;
      }
    }
    return data;
  }

  String get id {
    var id_string =
        "$offline_http_call_prefix $name $urlPath $storageContainer $httpMethod";
    return id_string.slug;
  }

  factory OfflineHttpCall.fromJson(Map<String, dynamic> json) =>
      _$OfflineHttpCallFromJson(json);
  Map<String, dynamic> toJson() => _$OfflineHttpCallToJson(this);
}

class APIConfig {
  late String apiEndpoint;
  late String version;
  late String clientId;
  late String? tokenUrl;
  late String? profileUrl;
  late String? revokeTokenUrl;
  late String? grantType;

  APIConfig({
    required this.apiEndpoint,
    required this.clientId,
    this.version = "api/v1",
    this.tokenUrl = "auth/token/",
    this.revokeTokenUrl = "auth/revoke-token/",
    this.profileUrl = "api/v1/users/me/",
    this.grantType = "password",
  });

  @override
  String toString() {
    // TODO: implement toString
    return "${apiEndpoint} ${version} ${tokenUrl}";
  }
}
