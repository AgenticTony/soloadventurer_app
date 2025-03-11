// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthSessionImpl _$$AuthSessionImplFromJson(Map<String, dynamic> json) =>
    _$AuthSessionImpl(
      accessToken: json['accessToken'] as String,
      idToken: json['idToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$AuthSessionImplToJson(_$AuthSessionImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'idToken': instance.idToken,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
