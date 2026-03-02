// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curated_pack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CuratedPackImpl _$$CuratedPackImplFromJson(Map<String, dynamic> json) =>
    _$CuratedPackImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      hobbies: (json['hobbies'] as List<dynamic>)
          .map((e) => Hobby.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CuratedPackImplToJson(_$CuratedPackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'icon': instance.icon,
      'hobbies': instance.hobbies.map((e) => e.toJson()).toList(),
    };
