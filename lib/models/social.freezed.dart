// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) {
  return _JournalEntry.fromJson(json);
}

/// @nodoc
mixin _$JournalEntry {
  String get id => throw _privateConstructorUsedError;
  String get hobbyId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this JournalEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JournalEntryCopyWith<JournalEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalEntryCopyWith<$Res> {
  factory $JournalEntryCopyWith(
          JournalEntry value, $Res Function(JournalEntry) then) =
      _$JournalEntryCopyWithImpl<$Res, JournalEntry>;
  @useResult
  $Res call(
      {String id,
      String hobbyId,
      String text,
      String? photoUrl,
      DateTime createdAt});
}

/// @nodoc
class _$JournalEntryCopyWithImpl<$Res, $Val extends JournalEntry>
    implements $JournalEntryCopyWith<$Res> {
  _$JournalEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hobbyId = null,
    Object? text = null,
    Object? photoUrl = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JournalEntryImplCopyWith<$Res>
    implements $JournalEntryCopyWith<$Res> {
  factory _$$JournalEntryImplCopyWith(
          _$JournalEntryImpl value, $Res Function(_$JournalEntryImpl) then) =
      __$$JournalEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String hobbyId,
      String text,
      String? photoUrl,
      DateTime createdAt});
}

/// @nodoc
class __$$JournalEntryImplCopyWithImpl<$Res>
    extends _$JournalEntryCopyWithImpl<$Res, _$JournalEntryImpl>
    implements _$$JournalEntryImplCopyWith<$Res> {
  __$$JournalEntryImplCopyWithImpl(
      _$JournalEntryImpl _value, $Res Function(_$JournalEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hobbyId = null,
    Object? text = null,
    Object? photoUrl = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$JournalEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JournalEntryImpl implements _JournalEntry {
  const _$JournalEntryImpl(
      {required this.id,
      required this.hobbyId,
      required this.text,
      this.photoUrl,
      required this.createdAt});

  factory _$JournalEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$JournalEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String hobbyId;
  @override
  final String text;
  @override
  final String? photoUrl;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'JournalEntry(id: $id, hobbyId: $hobbyId, text: $text, photoUrl: $photoUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hobbyId, hobbyId) || other.hobbyId == hobbyId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, hobbyId, text, photoUrl, createdAt);

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      __$$JournalEntryImplCopyWithImpl<_$JournalEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JournalEntryImplToJson(
      this,
    );
  }
}

abstract class _JournalEntry implements JournalEntry {
  const factory _JournalEntry(
      {required final String id,
      required final String hobbyId,
      required final String text,
      final String? photoUrl,
      required final DateTime createdAt}) = _$JournalEntryImpl;

  factory _JournalEntry.fromJson(Map<String, dynamic> json) =
      _$JournalEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get hobbyId;
  @override
  String get text;
  @override
  String? get photoUrl;
  @override
  DateTime get createdAt;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BuddyProfile _$BuddyProfileFromJson(Map<String, dynamic> json) {
  return _BuddyProfile.fromJson(json);
}

/// @nodoc
mixin _$BuddyProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get avatarInitial => throw _privateConstructorUsedError;
  String get currentHobbyId => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;

  /// Serializes this BuddyProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BuddyProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuddyProfileCopyWith<BuddyProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddyProfileCopyWith<$Res> {
  factory $BuddyProfileCopyWith(
          BuddyProfile value, $Res Function(BuddyProfile) then) =
      _$BuddyProfileCopyWithImpl<$Res, BuddyProfile>;
  @useResult
  $Res call(
      {String id,
      String name,
      String avatarInitial,
      String currentHobbyId,
      double progress});
}

/// @nodoc
class _$BuddyProfileCopyWithImpl<$Res, $Val extends BuddyProfile>
    implements $BuddyProfileCopyWith<$Res> {
  _$BuddyProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BuddyProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarInitial = null,
    Object? currentHobbyId = null,
    Object? progress = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarInitial: null == avatarInitial
          ? _value.avatarInitial
          : avatarInitial // ignore: cast_nullable_to_non_nullable
              as String,
      currentHobbyId: null == currentHobbyId
          ? _value.currentHobbyId
          : currentHobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuddyProfileImplCopyWith<$Res>
    implements $BuddyProfileCopyWith<$Res> {
  factory _$$BuddyProfileImplCopyWith(
          _$BuddyProfileImpl value, $Res Function(_$BuddyProfileImpl) then) =
      __$$BuddyProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String avatarInitial,
      String currentHobbyId,
      double progress});
}

/// @nodoc
class __$$BuddyProfileImplCopyWithImpl<$Res>
    extends _$BuddyProfileCopyWithImpl<$Res, _$BuddyProfileImpl>
    implements _$$BuddyProfileImplCopyWith<$Res> {
  __$$BuddyProfileImplCopyWithImpl(
      _$BuddyProfileImpl _value, $Res Function(_$BuddyProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of BuddyProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarInitial = null,
    Object? currentHobbyId = null,
    Object? progress = null,
  }) {
    return _then(_$BuddyProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarInitial: null == avatarInitial
          ? _value.avatarInitial
          : avatarInitial // ignore: cast_nullable_to_non_nullable
              as String,
      currentHobbyId: null == currentHobbyId
          ? _value.currentHobbyId
          : currentHobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuddyProfileImpl implements _BuddyProfile {
  const _$BuddyProfileImpl(
      {required this.id,
      required this.name,
      required this.avatarInitial,
      required this.currentHobbyId,
      required this.progress});

  factory _$BuddyProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddyProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String avatarInitial;
  @override
  final String currentHobbyId;
  @override
  final double progress;

  @override
  String toString() {
    return 'BuddyProfile(id: $id, name: $name, avatarInitial: $avatarInitial, currentHobbyId: $currentHobbyId, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddyProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarInitial, avatarInitial) ||
                other.avatarInitial == avatarInitial) &&
            (identical(other.currentHobbyId, currentHobbyId) ||
                other.currentHobbyId == currentHobbyId) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, avatarInitial, currentHobbyId, progress);

  /// Create a copy of BuddyProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddyProfileImplCopyWith<_$BuddyProfileImpl> get copyWith =>
      __$$BuddyProfileImplCopyWithImpl<_$BuddyProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddyProfileImplToJson(
      this,
    );
  }
}

abstract class _BuddyProfile implements BuddyProfile {
  const factory _BuddyProfile(
      {required final String id,
      required final String name,
      required final String avatarInitial,
      required final String currentHobbyId,
      required final double progress}) = _$BuddyProfileImpl;

  factory _BuddyProfile.fromJson(Map<String, dynamic> json) =
      _$BuddyProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get avatarInitial;
  @override
  String get currentHobbyId;
  @override
  double get progress;

  /// Create a copy of BuddyProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuddyProfileImplCopyWith<_$BuddyProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BuddyActivity _$BuddyActivityFromJson(Map<String, dynamic> json) {
  return _BuddyActivity.fromJson(json);
}

/// @nodoc
mixin _$BuddyActivity {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this BuddyActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BuddyActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuddyActivityCopyWith<BuddyActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddyActivityCopyWith<$Res> {
  factory $BuddyActivityCopyWith(
          BuddyActivity value, $Res Function(BuddyActivity) then) =
      _$BuddyActivityCopyWithImpl<$Res, BuddyActivity>;
  @useResult
  $Res call({String userId, String userName, String text, DateTime timestamp});
}

/// @nodoc
class _$BuddyActivityCopyWithImpl<$Res, $Val extends BuddyActivity>
    implements $BuddyActivityCopyWith<$Res> {
  _$BuddyActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BuddyActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? text = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuddyActivityImplCopyWith<$Res>
    implements $BuddyActivityCopyWith<$Res> {
  factory _$$BuddyActivityImplCopyWith(
          _$BuddyActivityImpl value, $Res Function(_$BuddyActivityImpl) then) =
      __$$BuddyActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String userName, String text, DateTime timestamp});
}

/// @nodoc
class __$$BuddyActivityImplCopyWithImpl<$Res>
    extends _$BuddyActivityCopyWithImpl<$Res, _$BuddyActivityImpl>
    implements _$$BuddyActivityImplCopyWith<$Res> {
  __$$BuddyActivityImplCopyWithImpl(
      _$BuddyActivityImpl _value, $Res Function(_$BuddyActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of BuddyActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? text = null,
    Object? timestamp = null,
  }) {
    return _then(_$BuddyActivityImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuddyActivityImpl implements _BuddyActivity {
  const _$BuddyActivityImpl(
      {required this.userId,
      required this.userName,
      required this.text,
      required this.timestamp});

  factory _$BuddyActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddyActivityImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String text;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'BuddyActivity(userId: $userId, userName: $userName, text: $text, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddyActivityImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, text, timestamp);

  /// Create a copy of BuddyActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddyActivityImplCopyWith<_$BuddyActivityImpl> get copyWith =>
      __$$BuddyActivityImplCopyWithImpl<_$BuddyActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddyActivityImplToJson(
      this,
    );
  }
}

abstract class _BuddyActivity implements BuddyActivity {
  const factory _BuddyActivity(
      {required final String userId,
      required final String userName,
      required final String text,
      required final DateTime timestamp}) = _$BuddyActivityImpl;

  factory _BuddyActivity.fromJson(Map<String, dynamic> json) =
      _$BuddyActivityImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String get text;
  @override
  DateTime get timestamp;

  /// Create a copy of BuddyActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuddyActivityImplCopyWith<_$BuddyActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommunityStory _$CommunityStoryFromJson(Map<String, dynamic> json) {
  return _CommunityStory.fromJson(json);
}

/// @nodoc
mixin _$CommunityStory {
  String get id => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  String get authorInitial => throw _privateConstructorUsedError;
  String get quote => throw _privateConstructorUsedError;
  String get hobbyId => throw _privateConstructorUsedError;
  Map<String, int> get reactions => throw _privateConstructorUsedError;
  List<String> get userReactions => throw _privateConstructorUsedError;

  /// Serializes this CommunityStory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityStory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityStoryCopyWith<CommunityStory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityStoryCopyWith<$Res> {
  factory $CommunityStoryCopyWith(
          CommunityStory value, $Res Function(CommunityStory) then) =
      _$CommunityStoryCopyWithImpl<$Res, CommunityStory>;
  @useResult
  $Res call(
      {String id,
      String authorName,
      String authorInitial,
      String quote,
      String hobbyId,
      Map<String, int> reactions,
      List<String> userReactions});
}

/// @nodoc
class _$CommunityStoryCopyWithImpl<$Res, $Val extends CommunityStory>
    implements $CommunityStoryCopyWith<$Res> {
  _$CommunityStoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityStory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorName = null,
    Object? authorInitial = null,
    Object? quote = null,
    Object? hobbyId = null,
    Object? reactions = null,
    Object? userReactions = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      authorInitial: null == authorInitial
          ? _value.authorInitial
          : authorInitial // ignore: cast_nullable_to_non_nullable
              as String,
      quote: null == quote
          ? _value.quote
          : quote // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      userReactions: null == userReactions
          ? _value.userReactions
          : userReactions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityStoryImplCopyWith<$Res>
    implements $CommunityStoryCopyWith<$Res> {
  factory _$$CommunityStoryImplCopyWith(_$CommunityStoryImpl value,
          $Res Function(_$CommunityStoryImpl) then) =
      __$$CommunityStoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String authorName,
      String authorInitial,
      String quote,
      String hobbyId,
      Map<String, int> reactions,
      List<String> userReactions});
}

/// @nodoc
class __$$CommunityStoryImplCopyWithImpl<$Res>
    extends _$CommunityStoryCopyWithImpl<$Res, _$CommunityStoryImpl>
    implements _$$CommunityStoryImplCopyWith<$Res> {
  __$$CommunityStoryImplCopyWithImpl(
      _$CommunityStoryImpl _value, $Res Function(_$CommunityStoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommunityStory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorName = null,
    Object? authorInitial = null,
    Object? quote = null,
    Object? hobbyId = null,
    Object? reactions = null,
    Object? userReactions = null,
  }) {
    return _then(_$CommunityStoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      authorInitial: null == authorInitial
          ? _value.authorInitial
          : authorInitial // ignore: cast_nullable_to_non_nullable
              as String,
      quote: null == quote
          ? _value.quote
          : quote // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      reactions: null == reactions
          ? _value._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      userReactions: null == userReactions
          ? _value._userReactions
          : userReactions // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityStoryImpl implements _CommunityStory {
  const _$CommunityStoryImpl(
      {required this.id,
      required this.authorName,
      required this.authorInitial,
      required this.quote,
      required this.hobbyId,
      final Map<String, int> reactions = const {},
      final List<String> userReactions = const []})
      : _reactions = reactions,
        _userReactions = userReactions;

  factory _$CommunityStoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityStoryImplFromJson(json);

  @override
  final String id;
  @override
  final String authorName;
  @override
  final String authorInitial;
  @override
  final String quote;
  @override
  final String hobbyId;
  final Map<String, int> _reactions;
  @override
  @JsonKey()
  Map<String, int> get reactions {
    if (_reactions is EqualUnmodifiableMapView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reactions);
  }

  final List<String> _userReactions;
  @override
  @JsonKey()
  List<String> get userReactions {
    if (_userReactions is EqualUnmodifiableListView) return _userReactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userReactions);
  }

  @override
  String toString() {
    return 'CommunityStory(id: $id, authorName: $authorName, authorInitial: $authorInitial, quote: $quote, hobbyId: $hobbyId, reactions: $reactions, userReactions: $userReactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityStoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorInitial, authorInitial) ||
                other.authorInitial == authorInitial) &&
            (identical(other.quote, quote) || other.quote == quote) &&
            (identical(other.hobbyId, hobbyId) || other.hobbyId == hobbyId) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions) &&
            const DeepCollectionEquality()
                .equals(other._userReactions, _userReactions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      authorName,
      authorInitial,
      quote,
      hobbyId,
      const DeepCollectionEquality().hash(_reactions),
      const DeepCollectionEquality().hash(_userReactions));

  /// Create a copy of CommunityStory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityStoryImplCopyWith<_$CommunityStoryImpl> get copyWith =>
      __$$CommunityStoryImplCopyWithImpl<_$CommunityStoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityStoryImplToJson(
      this,
    );
  }
}

abstract class _CommunityStory implements CommunityStory {
  const factory _CommunityStory(
      {required final String id,
      required final String authorName,
      required final String authorInitial,
      required final String quote,
      required final String hobbyId,
      final Map<String, int> reactions,
      final List<String> userReactions}) = _$CommunityStoryImpl;

  factory _CommunityStory.fromJson(Map<String, dynamic> json) =
      _$CommunityStoryImpl.fromJson;

  @override
  String get id;
  @override
  String get authorName;
  @override
  String get authorInitial;
  @override
  String get quote;
  @override
  String get hobbyId;
  @override
  Map<String, int> get reactions;
  @override
  List<String> get userReactions;

  /// Create a copy of CommunityStory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityStoryImplCopyWith<_$CommunityStoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NearbyUser _$NearbyUserFromJson(Map<String, dynamic> json) {
  return _NearbyUser.fromJson(json);
}

/// @nodoc
mixin _$NearbyUser {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get avatarInitial => throw _privateConstructorUsedError;
  String get hobbyId => throw _privateConstructorUsedError;
  String get distance => throw _privateConstructorUsedError;
  String get startedText => throw _privateConstructorUsedError;

  /// Serializes this NearbyUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NearbyUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NearbyUserCopyWith<NearbyUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NearbyUserCopyWith<$Res> {
  factory $NearbyUserCopyWith(
          NearbyUser value, $Res Function(NearbyUser) then) =
      _$NearbyUserCopyWithImpl<$Res, NearbyUser>;
  @useResult
  $Res call(
      {String id,
      String name,
      String avatarInitial,
      String hobbyId,
      String distance,
      String startedText});
}

/// @nodoc
class _$NearbyUserCopyWithImpl<$Res, $Val extends NearbyUser>
    implements $NearbyUserCopyWith<$Res> {
  _$NearbyUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NearbyUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarInitial = null,
    Object? hobbyId = null,
    Object? distance = null,
    Object? startedText = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarInitial: null == avatarInitial
          ? _value.avatarInitial
          : avatarInitial // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String,
      startedText: null == startedText
          ? _value.startedText
          : startedText // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NearbyUserImplCopyWith<$Res>
    implements $NearbyUserCopyWith<$Res> {
  factory _$$NearbyUserImplCopyWith(
          _$NearbyUserImpl value, $Res Function(_$NearbyUserImpl) then) =
      __$$NearbyUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String avatarInitial,
      String hobbyId,
      String distance,
      String startedText});
}

/// @nodoc
class __$$NearbyUserImplCopyWithImpl<$Res>
    extends _$NearbyUserCopyWithImpl<$Res, _$NearbyUserImpl>
    implements _$$NearbyUserImplCopyWith<$Res> {
  __$$NearbyUserImplCopyWithImpl(
      _$NearbyUserImpl _value, $Res Function(_$NearbyUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of NearbyUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarInitial = null,
    Object? hobbyId = null,
    Object? distance = null,
    Object? startedText = null,
  }) {
    return _then(_$NearbyUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarInitial: null == avatarInitial
          ? _value.avatarInitial
          : avatarInitial // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String,
      startedText: null == startedText
          ? _value.startedText
          : startedText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NearbyUserImpl implements _NearbyUser {
  const _$NearbyUserImpl(
      {required this.id,
      required this.name,
      required this.avatarInitial,
      required this.hobbyId,
      required this.distance,
      required this.startedText});

  factory _$NearbyUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$NearbyUserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String avatarInitial;
  @override
  final String hobbyId;
  @override
  final String distance;
  @override
  final String startedText;

  @override
  String toString() {
    return 'NearbyUser(id: $id, name: $name, avatarInitial: $avatarInitial, hobbyId: $hobbyId, distance: $distance, startedText: $startedText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NearbyUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarInitial, avatarInitial) ||
                other.avatarInitial == avatarInitial) &&
            (identical(other.hobbyId, hobbyId) || other.hobbyId == hobbyId) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.startedText, startedText) ||
                other.startedText == startedText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, avatarInitial, hobbyId, distance, startedText);

  /// Create a copy of NearbyUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NearbyUserImplCopyWith<_$NearbyUserImpl> get copyWith =>
      __$$NearbyUserImplCopyWithImpl<_$NearbyUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NearbyUserImplToJson(
      this,
    );
  }
}

abstract class _NearbyUser implements NearbyUser {
  const factory _NearbyUser(
      {required final String id,
      required final String name,
      required final String avatarInitial,
      required final String hobbyId,
      required final String distance,
      required final String startedText}) = _$NearbyUserImpl;

  factory _NearbyUser.fromJson(Map<String, dynamic> json) =
      _$NearbyUserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get avatarInitial;
  @override
  String get hobbyId;
  @override
  String get distance;
  @override
  String get startedText;

  /// Create a copy of NearbyUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NearbyUserImplCopyWith<_$NearbyUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BuddyRequest _$BuddyRequestFromJson(Map<String, dynamic> json) {
  return _BuddyRequest.fromJson(json);
}

/// @nodoc
mixin _$BuddyRequest {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get avatarInitial => throw _privateConstructorUsedError;
  String? get hobbyId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get direction => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BuddyRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BuddyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuddyRequestCopyWith<BuddyRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddyRequestCopyWith<$Res> {
  factory $BuddyRequestCopyWith(
          BuddyRequest value, $Res Function(BuddyRequest) then) =
      _$BuddyRequestCopyWithImpl<$Res, BuddyRequest>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String avatarInitial,
      String? hobbyId,
      String status,
      String direction,
      DateTime createdAt});
}

/// @nodoc
class _$BuddyRequestCopyWithImpl<$Res, $Val extends BuddyRequest>
    implements $BuddyRequestCopyWith<$Res> {
  _$BuddyRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BuddyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? avatarInitial = null,
    Object? hobbyId = freezed,
    Object? status = null,
    Object? direction = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarInitial: null == avatarInitial
          ? _value.avatarInitial
          : avatarInitial // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: freezed == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuddyRequestImplCopyWith<$Res>
    implements $BuddyRequestCopyWith<$Res> {
  factory _$$BuddyRequestImplCopyWith(
          _$BuddyRequestImpl value, $Res Function(_$BuddyRequestImpl) then) =
      __$$BuddyRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String avatarInitial,
      String? hobbyId,
      String status,
      String direction,
      DateTime createdAt});
}

/// @nodoc
class __$$BuddyRequestImplCopyWithImpl<$Res>
    extends _$BuddyRequestCopyWithImpl<$Res, _$BuddyRequestImpl>
    implements _$$BuddyRequestImplCopyWith<$Res> {
  __$$BuddyRequestImplCopyWithImpl(
      _$BuddyRequestImpl _value, $Res Function(_$BuddyRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of BuddyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? avatarInitial = null,
    Object? hobbyId = freezed,
    Object? status = null,
    Object? direction = null,
    Object? createdAt = null,
  }) {
    return _then(_$BuddyRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarInitial: null == avatarInitial
          ? _value.avatarInitial
          : avatarInitial // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: freezed == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuddyRequestImpl implements _BuddyRequest {
  const _$BuddyRequestImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.avatarInitial,
      this.hobbyId,
      required this.status,
      required this.direction,
      required this.createdAt});

  factory _$BuddyRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddyRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String avatarInitial;
  @override
  final String? hobbyId;
  @override
  final String status;
  @override
  final String direction;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'BuddyRequest(id: $id, userId: $userId, name: $name, avatarInitial: $avatarInitial, hobbyId: $hobbyId, status: $status, direction: $direction, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddyRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarInitial, avatarInitial) ||
                other.avatarInitial == avatarInitial) &&
            (identical(other.hobbyId, hobbyId) || other.hobbyId == hobbyId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, name, avatarInitial,
      hobbyId, status, direction, createdAt);

  /// Create a copy of BuddyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddyRequestImplCopyWith<_$BuddyRequestImpl> get copyWith =>
      __$$BuddyRequestImplCopyWithImpl<_$BuddyRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddyRequestImplToJson(
      this,
    );
  }
}

abstract class _BuddyRequest implements BuddyRequest {
  const factory _BuddyRequest(
      {required final String id,
      required final String userId,
      required final String name,
      required final String avatarInitial,
      final String? hobbyId,
      required final String status,
      required final String direction,
      required final DateTime createdAt}) = _$BuddyRequestImpl;

  factory _BuddyRequest.fromJson(Map<String, dynamic> json) =
      _$BuddyRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get avatarInitial;
  @override
  String? get hobbyId;
  @override
  String get status;
  @override
  String get direction;
  @override
  DateTime get createdAt;

  /// Create a copy of BuddyRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuddyRequestImplCopyWith<_$BuddyRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
