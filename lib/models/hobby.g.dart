// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hobby.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HobbyImpl _$$HobbyImplFromJson(Map<String, dynamic> json) => _$HobbyImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      hook: json['hook'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      costText: json['costText'] as String,
      timeText: json['timeText'] as String,
      difficultyText: json['difficultyText'] as String,
      whyLove: json['whyLove'] as String,
      difficultyExplain: json['difficultyExplain'] as String,
      starterKit: (json['starterKit'] as List<dynamic>)
          .map((e) => KitItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pitfalls:
          (json['pitfalls'] as List<dynamic>).map((e) => e as String).toList(),
      roadmapSteps: (json['roadmapSteps'] as List<dynamic>)
          .map((e) => RoadmapStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$HobbyImplToJson(_$HobbyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'hook': instance.hook,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
      'costText': instance.costText,
      'timeText': instance.timeText,
      'difficultyText': instance.difficultyText,
      'whyLove': instance.whyLove,
      'difficultyExplain': instance.difficultyExplain,
      'starterKit': instance.starterKit.map((e) => e.toJson()).toList(),
      'pitfalls': instance.pitfalls,
      'roadmapSteps': instance.roadmapSteps.map((e) => e.toJson()).toList(),
    };

_$KitItemImpl _$$KitItemImplFromJson(Map<String, dynamic> json) =>
    _$KitItemImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num).toInt(),
      isOptional: json['isOptional'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      affiliateUrl: json['affiliateUrl'] as String?,
      affiliateSource: json['affiliateSource'] as String?,
    );

Map<String, dynamic> _$$KitItemImplToJson(_$KitItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'cost': instance.cost,
      'isOptional': instance.isOptional,
      'imageUrl': instance.imageUrl,
      'affiliateUrl': instance.affiliateUrl,
      'affiliateSource': instance.affiliateSource,
    };

_$RoadmapStepImpl _$$RoadmapStepImplFromJson(Map<String, dynamic> json) =>
    _$RoadmapStepImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
      milestone: json['milestone'] as String?,
    );

Map<String, dynamic> _$$RoadmapStepImplToJson(_$RoadmapStepImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'estimatedMinutes': instance.estimatedMinutes,
      'milestone': instance.milestone,
    };

_$HobbyCategoryImpl _$$HobbyCategoryImplFromJson(Map<String, dynamic> json) =>
    _$HobbyCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      count: (json['count'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$$HobbyCategoryImplToJson(_$HobbyCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'count': instance.count,
      'imageUrl': instance.imageUrl,
    };

_$UserHobbyImpl _$$UserHobbyImplFromJson(Map<String, dynamic> json) =>
    _$UserHobbyImpl(
      hobbyId: json['hobbyId'] as String,
      status: $enumDecode(_$HobbyStatusEnumMap, json['status']),
      completedStepIds: json['completedStepIds'] == null
          ? const <String>{}
          : const SetStringConverter()
              .fromJson(json['completedStepIds'] as List),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserHobbyImplToJson(_$UserHobbyImpl instance) =>
    <String, dynamic>{
      'hobbyId': instance.hobbyId,
      'status': _$HobbyStatusEnumMap[instance.status]!,
      'completedStepIds':
          const SetStringConverter().toJson(instance.completedStepIds),
      'startedAt': instance.startedAt?.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
      'streakDays': instance.streakDays,
    };

const _$HobbyStatusEnumMap = {
  HobbyStatus.saved: 'saved',
  HobbyStatus.trying: 'trying',
  HobbyStatus.active: 'active',
  HobbyStatus.done: 'done',
};

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      hoursPerWeek: (json['hoursPerWeek'] as num?)?.toInt() ?? 3,
      budgetLevel: (json['budgetLevel'] as num?)?.toInt() ?? 1,
      preferSocial: json['preferSocial'] as bool? ?? false,
      vibes: json['vibes'] == null
          ? const <String>{}
          : const SetStringConverter().fromJson(json['vibes'] as List),
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'hoursPerWeek': instance.hoursPerWeek,
      'budgetLevel': instance.budgetLevel,
      'preferSocial': instance.preferSocial,
      'vibes': const SetStringConverter().toJson(instance.vibes),
    };
