// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthUserImpl _$$AuthUserImplFromJson(Map<String, dynamic> json) =>
    _$AuthUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] as String?,
      hasPassword: json['hasPassword'] as bool? ?? true,
    );

Map<String, dynamic> _$$AuthUserImplToJson(_$AuthUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'createdAt': instance.createdAt,
      'hasPassword': instance.hasPassword,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
