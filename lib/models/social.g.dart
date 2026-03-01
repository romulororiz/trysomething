// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JournalEntryImpl _$$JournalEntryImplFromJson(Map<String, dynamic> json) =>
    _$JournalEntryImpl(
      id: json['id'] as String,
      hobbyId: json['hobbyId'] as String,
      text: json['text'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$JournalEntryImplToJson(_$JournalEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hobbyId': instance.hobbyId,
      'text': instance.text,
      'photoUrl': instance.photoUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$BuddyProfileImpl _$$BuddyProfileImplFromJson(Map<String, dynamic> json) =>
    _$BuddyProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarInitial: json['avatarInitial'] as String,
      currentHobbyId: json['currentHobbyId'] as String,
      progress: (json['progress'] as num).toDouble(),
    );

Map<String, dynamic> _$$BuddyProfileImplToJson(_$BuddyProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarInitial': instance.avatarInitial,
      'currentHobbyId': instance.currentHobbyId,
      'progress': instance.progress,
    };

_$BuddyActivityImpl _$$BuddyActivityImplFromJson(Map<String, dynamic> json) =>
    _$BuddyActivityImpl(
      userId: json['userId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$BuddyActivityImplToJson(_$BuddyActivityImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_$CommunityStoryImpl _$$CommunityStoryImplFromJson(Map<String, dynamic> json) =>
    _$CommunityStoryImpl(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorInitial: json['authorInitial'] as String,
      quote: json['quote'] as String,
      hobbyId: json['hobbyId'] as String,
      reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$CommunityStoryImplToJson(
        _$CommunityStoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorName': instance.authorName,
      'authorInitial': instance.authorInitial,
      'quote': instance.quote,
      'hobbyId': instance.hobbyId,
      'reactions': instance.reactions,
    };

_$NearbyUserImpl _$$NearbyUserImplFromJson(Map<String, dynamic> json) =>
    _$NearbyUserImpl(
      name: json['name'] as String,
      avatarInitial: json['avatarInitial'] as String,
      hobbyId: json['hobbyId'] as String,
      distance: json['distance'] as String,
      startedText: json['startedText'] as String,
    );

Map<String, dynamic> _$$NearbyUserImplToJson(_$NearbyUserImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatarInitial': instance.avatarInitial,
      'hobbyId': instance.hobbyId,
      'distance': instance.distance,
      'startedText': instance.startedText,
    };
