// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'features.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      username: json['username'] as String? ?? 'Your Name',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
    };

_$ChallengeImpl _$$ChallengeImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetCount: (json['targetCount'] as num).toInt(),
      currentCount: (json['currentCount'] as num?)?.toInt() ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$ChallengeImplToJson(_$ChallengeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'targetCount': instance.targetCount,
      'currentCount': instance.currentCount,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isCompleted': instance.isCompleted,
    };

_$ScheduleEventImpl _$$ScheduleEventImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleEventImpl(
      id: json['id'] as String,
      hobbyId: json['hobbyId'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: json['startTime'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$$ScheduleEventImplToJson(_$ScheduleEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hobbyId': instance.hobbyId,
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'durationMinutes': instance.durationMinutes,
    };

_$HobbyComboImpl _$$HobbyComboImplFromJson(Map<String, dynamic> json) =>
    _$HobbyComboImpl(
      hobbyId1: json['hobbyId1'] as String,
      hobbyId2: json['hobbyId2'] as String,
      reason: json['reason'] as String,
      sharedTags: (json['sharedTags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$HobbyComboImplToJson(_$HobbyComboImpl instance) =>
    <String, dynamic>{
      'hobbyId1': instance.hobbyId1,
      'hobbyId2': instance.hobbyId2,
      'reason': instance.reason,
      'sharedTags': instance.sharedTags,
    };

_$FaqItemImpl _$$FaqItemImplFromJson(Map<String, dynamic> json) =>
    _$FaqItemImpl(
      id: json['id'] as String? ?? '',
      question: json['question'] as String,
      answer: json['answer'] as String,
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FaqItemImplToJson(_$FaqItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'upvotes': instance.upvotes,
      'helpfulCount': instance.helpfulCount,
    };

_$CostBreakdownImpl _$$CostBreakdownImplFromJson(Map<String, dynamic> json) =>
    _$CostBreakdownImpl(
      starter: (json['starter'] as num).toInt(),
      threeMonth: (json['threeMonth'] as num).toInt(),
      oneYear: (json['oneYear'] as num).toInt(),
      tips:
          (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$CostBreakdownImplToJson(_$CostBreakdownImpl instance) =>
    <String, dynamic>{
      'starter': instance.starter,
      'threeMonth': instance.threeMonth,
      'oneYear': instance.oneYear,
      'tips': instance.tips,
    };

_$BudgetAlternativeImpl _$$BudgetAlternativeImplFromJson(
        Map<String, dynamic> json) =>
    _$BudgetAlternativeImpl(
      itemName: json['itemName'] as String,
      diyOption: json['diyOption'] as String,
      diyCost: (json['diyCost'] as num).toInt(),
      budgetOption: json['budgetOption'] as String,
      budgetCost: (json['budgetCost'] as num).toInt(),
      premiumOption: json['premiumOption'] as String,
      premiumCost: (json['premiumCost'] as num).toInt(),
    );

Map<String, dynamic> _$$BudgetAlternativeImplToJson(
        _$BudgetAlternativeImpl instance) =>
    <String, dynamic>{
      'itemName': instance.itemName,
      'diyOption': instance.diyOption,
      'diyCost': instance.diyCost,
      'budgetOption': instance.budgetOption,
      'budgetCost': instance.budgetCost,
      'premiumOption': instance.premiumOption,
      'premiumCost': instance.premiumCost,
    };
