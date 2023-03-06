// GENERATED CODE - DO NOT MODIFY BY HAND

part of flutter_utils;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineHttpCall _$OfflineHttpCallFromJson(Map<String, dynamic> json) =>
    OfflineHttpCall(
      formData: json['formData'],
      name: json['name'] as String,
      httpMethod: json['httpMethod'] as String,
      urlPath: json['urlPath'] as String,
      storageContainer: json['storageContainer'] as String? ?? "GetStorage",
    )
      ..status = json['status'] as String
      ..tries = json['tries'] as int;

Map<String, dynamic> _$OfflineHttpCallToJson(OfflineHttpCall instance) =>
    <String, dynamic>{
      'name': instance.name,
      'urlPath': instance.urlPath,
      'storageContainer': instance.storageContainer,
      'formData': instance.formData,
      'httpMethod': instance.httpMethod,
      'status': instance.status,
      'tries': instance.tries,
    };
