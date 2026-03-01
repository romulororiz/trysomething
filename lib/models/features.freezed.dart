// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'features.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get username => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({String username, String bio, String? avatarUrl});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? bio = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_value.copyWith(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username, String bio, String? avatarUrl});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? bio = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$UserProfileImpl(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {this.username = 'Your Name', this.bio = '', this.avatarUrl});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String bio;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'UserProfile(username: $username, bio: $bio, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username, bio, avatarUrl);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {final String username,
      final String bio,
      final String? avatarUrl}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get username;
  @override
  String get bio;
  @override
  String? get avatarUrl;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Challenge _$ChallengeFromJson(Map<String, dynamic> json) {
  return _Challenge.fromJson(json);
}

/// @nodoc
mixin _$Challenge {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get targetCount => throw _privateConstructorUsedError;
  int get currentCount => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this Challenge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeCopyWith<Challenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCopyWith<$Res> {
  factory $ChallengeCopyWith(Challenge value, $Res Function(Challenge) then) =
      _$ChallengeCopyWithImpl<$Res, Challenge>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int targetCount,
      int currentCount,
      DateTime startDate,
      DateTime endDate,
      bool isCompleted});
}

/// @nodoc
class _$ChallengeCopyWithImpl<$Res, $Val extends Challenge>
    implements $ChallengeCopyWith<$Res> {
  _$ChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? targetCount = null,
    Object? currentCount = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      targetCount: null == targetCount
          ? _value.targetCount
          : targetCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentCount: null == currentCount
          ? _value.currentCount
          : currentCount // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeImplCopyWith<$Res>
    implements $ChallengeCopyWith<$Res> {
  factory _$$ChallengeImplCopyWith(
          _$ChallengeImpl value, $Res Function(_$ChallengeImpl) then) =
      __$$ChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int targetCount,
      int currentCount,
      DateTime startDate,
      DateTime endDate,
      bool isCompleted});
}

/// @nodoc
class __$$ChallengeImplCopyWithImpl<$Res>
    extends _$ChallengeCopyWithImpl<$Res, _$ChallengeImpl>
    implements _$$ChallengeImplCopyWith<$Res> {
  __$$ChallengeImplCopyWithImpl(
      _$ChallengeImpl _value, $Res Function(_$ChallengeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? targetCount = null,
    Object? currentCount = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isCompleted = null,
  }) {
    return _then(_$ChallengeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      targetCount: null == targetCount
          ? _value.targetCount
          : targetCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentCount: null == currentCount
          ? _value.currentCount
          : currentCount // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeImpl extends _Challenge {
  const _$ChallengeImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.targetCount,
      this.currentCount = 0,
      required this.startDate,
      required this.endDate,
      this.isCompleted = false})
      : super._();

  factory _$ChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final int targetCount;
  @override
  @JsonKey()
  final int currentCount;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, description: $description, targetCount: $targetCount, currentCount: $currentCount, startDate: $startDate, endDate: $endDate, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.targetCount, targetCount) ||
                other.targetCount == targetCount) &&
            (identical(other.currentCount, currentCount) ||
                other.currentCount == currentCount) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description,
      targetCount, currentCount, startDate, endDate, isCompleted);

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      __$$ChallengeImplCopyWithImpl<_$ChallengeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeImplToJson(
      this,
    );
  }
}

abstract class _Challenge extends Challenge {
  const factory _Challenge(
      {required final String id,
      required final String title,
      required final String description,
      required final int targetCount,
      final int currentCount,
      required final DateTime startDate,
      required final DateTime endDate,
      final bool isCompleted}) = _$ChallengeImpl;
  const _Challenge._() : super._();

  factory _Challenge.fromJson(Map<String, dynamic> json) =
      _$ChallengeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  int get targetCount;
  @override
  int get currentCount;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  bool get isCompleted;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleEvent _$ScheduleEventFromJson(Map<String, dynamic> json) {
  return _ScheduleEvent.fromJson(json);
}

/// @nodoc
mixin _$ScheduleEvent {
  String get id => throw _privateConstructorUsedError;
  String get hobbyId => throw _privateConstructorUsedError;
  int get dayOfWeek => throw _privateConstructorUsedError; // 1=Mon, 7=Sun
  String get startTime => throw _privateConstructorUsedError; // "19:00"
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Serializes this ScheduleEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleEventCopyWith<ScheduleEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleEventCopyWith<$Res> {
  factory $ScheduleEventCopyWith(
          ScheduleEvent value, $Res Function(ScheduleEvent) then) =
      _$ScheduleEventCopyWithImpl<$Res, ScheduleEvent>;
  @useResult
  $Res call(
      {String id,
      String hobbyId,
      int dayOfWeek,
      String startTime,
      int durationMinutes});
}

/// @nodoc
class _$ScheduleEventCopyWithImpl<$Res, $Val extends ScheduleEvent>
    implements $ScheduleEventCopyWith<$Res> {
  _$ScheduleEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hobbyId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? durationMinutes = null,
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
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleEventImplCopyWith<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  factory _$$ScheduleEventImplCopyWith(
          _$ScheduleEventImpl value, $Res Function(_$ScheduleEventImpl) then) =
      __$$ScheduleEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String hobbyId,
      int dayOfWeek,
      String startTime,
      int durationMinutes});
}

/// @nodoc
class __$$ScheduleEventImplCopyWithImpl<$Res>
    extends _$ScheduleEventCopyWithImpl<$Res, _$ScheduleEventImpl>
    implements _$$ScheduleEventImplCopyWith<$Res> {
  __$$ScheduleEventImplCopyWithImpl(
      _$ScheduleEventImpl _value, $Res Function(_$ScheduleEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? hobbyId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? durationMinutes = null,
  }) {
    return _then(_$ScheduleEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleEventImpl implements _ScheduleEvent {
  const _$ScheduleEventImpl(
      {required this.id,
      required this.hobbyId,
      required this.dayOfWeek,
      required this.startTime,
      required this.durationMinutes});

  factory _$ScheduleEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleEventImplFromJson(json);

  @override
  final String id;
  @override
  final String hobbyId;
  @override
  final int dayOfWeek;
// 1=Mon, 7=Sun
  @override
  final String startTime;
// "19:00"
  @override
  final int durationMinutes;

  @override
  String toString() {
    return 'ScheduleEvent(id: $id, hobbyId: $hobbyId, dayOfWeek: $dayOfWeek, startTime: $startTime, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.hobbyId, hobbyId) || other.hobbyId == hobbyId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, hobbyId, dayOfWeek, startTime, durationMinutes);

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleEventImplCopyWith<_$ScheduleEventImpl> get copyWith =>
      __$$ScheduleEventImplCopyWithImpl<_$ScheduleEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleEventImplToJson(
      this,
    );
  }
}

abstract class _ScheduleEvent implements ScheduleEvent {
  const factory _ScheduleEvent(
      {required final String id,
      required final String hobbyId,
      required final int dayOfWeek,
      required final String startTime,
      required final int durationMinutes}) = _$ScheduleEventImpl;

  factory _ScheduleEvent.fromJson(Map<String, dynamic> json) =
      _$ScheduleEventImpl.fromJson;

  @override
  String get id;
  @override
  String get hobbyId;
  @override
  int get dayOfWeek; // 1=Mon, 7=Sun
  @override
  String get startTime; // "19:00"
  @override
  int get durationMinutes;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleEventImplCopyWith<_$ScheduleEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HobbyCombo _$HobbyComboFromJson(Map<String, dynamic> json) {
  return _HobbyCombo.fromJson(json);
}

/// @nodoc
mixin _$HobbyCombo {
  String get hobbyId1 => throw _privateConstructorUsedError;
  String get hobbyId2 => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  List<String> get sharedTags => throw _privateConstructorUsedError;

  /// Serializes this HobbyCombo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HobbyCombo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HobbyComboCopyWith<HobbyCombo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HobbyComboCopyWith<$Res> {
  factory $HobbyComboCopyWith(
          HobbyCombo value, $Res Function(HobbyCombo) then) =
      _$HobbyComboCopyWithImpl<$Res, HobbyCombo>;
  @useResult
  $Res call(
      {String hobbyId1,
      String hobbyId2,
      String reason,
      List<String> sharedTags});
}

/// @nodoc
class _$HobbyComboCopyWithImpl<$Res, $Val extends HobbyCombo>
    implements $HobbyComboCopyWith<$Res> {
  _$HobbyComboCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HobbyCombo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hobbyId1 = null,
    Object? hobbyId2 = null,
    Object? reason = null,
    Object? sharedTags = null,
  }) {
    return _then(_value.copyWith(
      hobbyId1: null == hobbyId1
          ? _value.hobbyId1
          : hobbyId1 // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId2: null == hobbyId2
          ? _value.hobbyId2
          : hobbyId2 // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      sharedTags: null == sharedTags
          ? _value.sharedTags
          : sharedTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HobbyComboImplCopyWith<$Res>
    implements $HobbyComboCopyWith<$Res> {
  factory _$$HobbyComboImplCopyWith(
          _$HobbyComboImpl value, $Res Function(_$HobbyComboImpl) then) =
      __$$HobbyComboImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String hobbyId1,
      String hobbyId2,
      String reason,
      List<String> sharedTags});
}

/// @nodoc
class __$$HobbyComboImplCopyWithImpl<$Res>
    extends _$HobbyComboCopyWithImpl<$Res, _$HobbyComboImpl>
    implements _$$HobbyComboImplCopyWith<$Res> {
  __$$HobbyComboImplCopyWithImpl(
      _$HobbyComboImpl _value, $Res Function(_$HobbyComboImpl) _then)
      : super(_value, _then);

  /// Create a copy of HobbyCombo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hobbyId1 = null,
    Object? hobbyId2 = null,
    Object? reason = null,
    Object? sharedTags = null,
  }) {
    return _then(_$HobbyComboImpl(
      hobbyId1: null == hobbyId1
          ? _value.hobbyId1
          : hobbyId1 // ignore: cast_nullable_to_non_nullable
              as String,
      hobbyId2: null == hobbyId2
          ? _value.hobbyId2
          : hobbyId2 // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      sharedTags: null == sharedTags
          ? _value._sharedTags
          : sharedTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HobbyComboImpl implements _HobbyCombo {
  const _$HobbyComboImpl(
      {required this.hobbyId1,
      required this.hobbyId2,
      required this.reason,
      required final List<String> sharedTags})
      : _sharedTags = sharedTags;

  factory _$HobbyComboImpl.fromJson(Map<String, dynamic> json) =>
      _$$HobbyComboImplFromJson(json);

  @override
  final String hobbyId1;
  @override
  final String hobbyId2;
  @override
  final String reason;
  final List<String> _sharedTags;
  @override
  List<String> get sharedTags {
    if (_sharedTags is EqualUnmodifiableListView) return _sharedTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sharedTags);
  }

  @override
  String toString() {
    return 'HobbyCombo(hobbyId1: $hobbyId1, hobbyId2: $hobbyId2, reason: $reason, sharedTags: $sharedTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HobbyComboImpl &&
            (identical(other.hobbyId1, hobbyId1) ||
                other.hobbyId1 == hobbyId1) &&
            (identical(other.hobbyId2, hobbyId2) ||
                other.hobbyId2 == hobbyId2) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            const DeepCollectionEquality()
                .equals(other._sharedTags, _sharedTags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hobbyId1, hobbyId2, reason,
      const DeepCollectionEquality().hash(_sharedTags));

  /// Create a copy of HobbyCombo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HobbyComboImplCopyWith<_$HobbyComboImpl> get copyWith =>
      __$$HobbyComboImplCopyWithImpl<_$HobbyComboImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HobbyComboImplToJson(
      this,
    );
  }
}

abstract class _HobbyCombo implements HobbyCombo {
  const factory _HobbyCombo(
      {required final String hobbyId1,
      required final String hobbyId2,
      required final String reason,
      required final List<String> sharedTags}) = _$HobbyComboImpl;

  factory _HobbyCombo.fromJson(Map<String, dynamic> json) =
      _$HobbyComboImpl.fromJson;

  @override
  String get hobbyId1;
  @override
  String get hobbyId2;
  @override
  String get reason;
  @override
  List<String> get sharedTags;

  /// Create a copy of HobbyCombo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HobbyComboImplCopyWith<_$HobbyComboImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FaqItem _$FaqItemFromJson(Map<String, dynamic> json) {
  return _FaqItem.fromJson(json);
}

/// @nodoc
mixin _$FaqItem {
  String get question => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;
  int get upvotes => throw _privateConstructorUsedError;

  /// Serializes this FaqItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FaqItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaqItemCopyWith<FaqItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaqItemCopyWith<$Res> {
  factory $FaqItemCopyWith(FaqItem value, $Res Function(FaqItem) then) =
      _$FaqItemCopyWithImpl<$Res, FaqItem>;
  @useResult
  $Res call({String question, String answer, int upvotes});
}

/// @nodoc
class _$FaqItemCopyWithImpl<$Res, $Val extends FaqItem>
    implements $FaqItemCopyWith<$Res> {
  _$FaqItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaqItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? answer = null,
    Object? upvotes = null,
  }) {
    return _then(_value.copyWith(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      upvotes: null == upvotes
          ? _value.upvotes
          : upvotes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FaqItemImplCopyWith<$Res> implements $FaqItemCopyWith<$Res> {
  factory _$$FaqItemImplCopyWith(
          _$FaqItemImpl value, $Res Function(_$FaqItemImpl) then) =
      __$$FaqItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String question, String answer, int upvotes});
}

/// @nodoc
class __$$FaqItemImplCopyWithImpl<$Res>
    extends _$FaqItemCopyWithImpl<$Res, _$FaqItemImpl>
    implements _$$FaqItemImplCopyWith<$Res> {
  __$$FaqItemImplCopyWithImpl(
      _$FaqItemImpl _value, $Res Function(_$FaqItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of FaqItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? answer = null,
    Object? upvotes = null,
  }) {
    return _then(_$FaqItemImpl(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      upvotes: null == upvotes
          ? _value.upvotes
          : upvotes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FaqItemImpl implements _FaqItem {
  const _$FaqItemImpl(
      {required this.question, required this.answer, this.upvotes = 0});

  factory _$FaqItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaqItemImplFromJson(json);

  @override
  final String question;
  @override
  final String answer;
  @override
  @JsonKey()
  final int upvotes;

  @override
  String toString() {
    return 'FaqItem(question: $question, answer: $answer, upvotes: $upvotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaqItemImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.upvotes, upvotes) || other.upvotes == upvotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, question, answer, upvotes);

  /// Create a copy of FaqItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaqItemImplCopyWith<_$FaqItemImpl> get copyWith =>
      __$$FaqItemImplCopyWithImpl<_$FaqItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaqItemImplToJson(
      this,
    );
  }
}

abstract class _FaqItem implements FaqItem {
  const factory _FaqItem(
      {required final String question,
      required final String answer,
      final int upvotes}) = _$FaqItemImpl;

  factory _FaqItem.fromJson(Map<String, dynamic> json) = _$FaqItemImpl.fromJson;

  @override
  String get question;
  @override
  String get answer;
  @override
  int get upvotes;

  /// Create a copy of FaqItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaqItemImplCopyWith<_$FaqItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CostBreakdown _$CostBreakdownFromJson(Map<String, dynamic> json) {
  return _CostBreakdown.fromJson(json);
}

/// @nodoc
mixin _$CostBreakdown {
  int get starter => throw _privateConstructorUsedError;
  int get threeMonth => throw _privateConstructorUsedError;
  int get oneYear => throw _privateConstructorUsedError;
  List<String> get tips => throw _privateConstructorUsedError;

  /// Serializes this CostBreakdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CostBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CostBreakdownCopyWith<CostBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CostBreakdownCopyWith<$Res> {
  factory $CostBreakdownCopyWith(
          CostBreakdown value, $Res Function(CostBreakdown) then) =
      _$CostBreakdownCopyWithImpl<$Res, CostBreakdown>;
  @useResult
  $Res call({int starter, int threeMonth, int oneYear, List<String> tips});
}

/// @nodoc
class _$CostBreakdownCopyWithImpl<$Res, $Val extends CostBreakdown>
    implements $CostBreakdownCopyWith<$Res> {
  _$CostBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CostBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? starter = null,
    Object? threeMonth = null,
    Object? oneYear = null,
    Object? tips = null,
  }) {
    return _then(_value.copyWith(
      starter: null == starter
          ? _value.starter
          : starter // ignore: cast_nullable_to_non_nullable
              as int,
      threeMonth: null == threeMonth
          ? _value.threeMonth
          : threeMonth // ignore: cast_nullable_to_non_nullable
              as int,
      oneYear: null == oneYear
          ? _value.oneYear
          : oneYear // ignore: cast_nullable_to_non_nullable
              as int,
      tips: null == tips
          ? _value.tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CostBreakdownImplCopyWith<$Res>
    implements $CostBreakdownCopyWith<$Res> {
  factory _$$CostBreakdownImplCopyWith(
          _$CostBreakdownImpl value, $Res Function(_$CostBreakdownImpl) then) =
      __$$CostBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int starter, int threeMonth, int oneYear, List<String> tips});
}

/// @nodoc
class __$$CostBreakdownImplCopyWithImpl<$Res>
    extends _$CostBreakdownCopyWithImpl<$Res, _$CostBreakdownImpl>
    implements _$$CostBreakdownImplCopyWith<$Res> {
  __$$CostBreakdownImplCopyWithImpl(
      _$CostBreakdownImpl _value, $Res Function(_$CostBreakdownImpl) _then)
      : super(_value, _then);

  /// Create a copy of CostBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? starter = null,
    Object? threeMonth = null,
    Object? oneYear = null,
    Object? tips = null,
  }) {
    return _then(_$CostBreakdownImpl(
      starter: null == starter
          ? _value.starter
          : starter // ignore: cast_nullable_to_non_nullable
              as int,
      threeMonth: null == threeMonth
          ? _value.threeMonth
          : threeMonth // ignore: cast_nullable_to_non_nullable
              as int,
      oneYear: null == oneYear
          ? _value.oneYear
          : oneYear // ignore: cast_nullable_to_non_nullable
              as int,
      tips: null == tips
          ? _value._tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CostBreakdownImpl implements _CostBreakdown {
  const _$CostBreakdownImpl(
      {required this.starter,
      required this.threeMonth,
      required this.oneYear,
      final List<String> tips = const []})
      : _tips = tips;

  factory _$CostBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$CostBreakdownImplFromJson(json);

  @override
  final int starter;
  @override
  final int threeMonth;
  @override
  final int oneYear;
  final List<String> _tips;
  @override
  @JsonKey()
  List<String> get tips {
    if (_tips is EqualUnmodifiableListView) return _tips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tips);
  }

  @override
  String toString() {
    return 'CostBreakdown(starter: $starter, threeMonth: $threeMonth, oneYear: $oneYear, tips: $tips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CostBreakdownImpl &&
            (identical(other.starter, starter) || other.starter == starter) &&
            (identical(other.threeMonth, threeMonth) ||
                other.threeMonth == threeMonth) &&
            (identical(other.oneYear, oneYear) || other.oneYear == oneYear) &&
            const DeepCollectionEquality().equals(other._tips, _tips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, starter, threeMonth, oneYear,
      const DeepCollectionEquality().hash(_tips));

  /// Create a copy of CostBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CostBreakdownImplCopyWith<_$CostBreakdownImpl> get copyWith =>
      __$$CostBreakdownImplCopyWithImpl<_$CostBreakdownImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CostBreakdownImplToJson(
      this,
    );
  }
}

abstract class _CostBreakdown implements CostBreakdown {
  const factory _CostBreakdown(
      {required final int starter,
      required final int threeMonth,
      required final int oneYear,
      final List<String> tips}) = _$CostBreakdownImpl;

  factory _CostBreakdown.fromJson(Map<String, dynamic> json) =
      _$CostBreakdownImpl.fromJson;

  @override
  int get starter;
  @override
  int get threeMonth;
  @override
  int get oneYear;
  @override
  List<String> get tips;

  /// Create a copy of CostBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CostBreakdownImplCopyWith<_$CostBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BudgetAlternative _$BudgetAlternativeFromJson(Map<String, dynamic> json) {
  return _BudgetAlternative.fromJson(json);
}

/// @nodoc
mixin _$BudgetAlternative {
  String get itemName => throw _privateConstructorUsedError;
  String get diyOption => throw _privateConstructorUsedError;
  int get diyCost => throw _privateConstructorUsedError;
  String get budgetOption => throw _privateConstructorUsedError;
  int get budgetCost => throw _privateConstructorUsedError;
  String get premiumOption => throw _privateConstructorUsedError;
  int get premiumCost => throw _privateConstructorUsedError;

  /// Serializes this BudgetAlternative to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BudgetAlternative
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetAlternativeCopyWith<BudgetAlternative> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetAlternativeCopyWith<$Res> {
  factory $BudgetAlternativeCopyWith(
          BudgetAlternative value, $Res Function(BudgetAlternative) then) =
      _$BudgetAlternativeCopyWithImpl<$Res, BudgetAlternative>;
  @useResult
  $Res call(
      {String itemName,
      String diyOption,
      int diyCost,
      String budgetOption,
      int budgetCost,
      String premiumOption,
      int premiumCost});
}

/// @nodoc
class _$BudgetAlternativeCopyWithImpl<$Res, $Val extends BudgetAlternative>
    implements $BudgetAlternativeCopyWith<$Res> {
  _$BudgetAlternativeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BudgetAlternative
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemName = null,
    Object? diyOption = null,
    Object? diyCost = null,
    Object? budgetOption = null,
    Object? budgetCost = null,
    Object? premiumOption = null,
    Object? premiumCost = null,
  }) {
    return _then(_value.copyWith(
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      diyOption: null == diyOption
          ? _value.diyOption
          : diyOption // ignore: cast_nullable_to_non_nullable
              as String,
      diyCost: null == diyCost
          ? _value.diyCost
          : diyCost // ignore: cast_nullable_to_non_nullable
              as int,
      budgetOption: null == budgetOption
          ? _value.budgetOption
          : budgetOption // ignore: cast_nullable_to_non_nullable
              as String,
      budgetCost: null == budgetCost
          ? _value.budgetCost
          : budgetCost // ignore: cast_nullable_to_non_nullable
              as int,
      premiumOption: null == premiumOption
          ? _value.premiumOption
          : premiumOption // ignore: cast_nullable_to_non_nullable
              as String,
      premiumCost: null == premiumCost
          ? _value.premiumCost
          : premiumCost // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BudgetAlternativeImplCopyWith<$Res>
    implements $BudgetAlternativeCopyWith<$Res> {
  factory _$$BudgetAlternativeImplCopyWith(_$BudgetAlternativeImpl value,
          $Res Function(_$BudgetAlternativeImpl) then) =
      __$$BudgetAlternativeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String itemName,
      String diyOption,
      int diyCost,
      String budgetOption,
      int budgetCost,
      String premiumOption,
      int premiumCost});
}

/// @nodoc
class __$$BudgetAlternativeImplCopyWithImpl<$Res>
    extends _$BudgetAlternativeCopyWithImpl<$Res, _$BudgetAlternativeImpl>
    implements _$$BudgetAlternativeImplCopyWith<$Res> {
  __$$BudgetAlternativeImplCopyWithImpl(_$BudgetAlternativeImpl _value,
      $Res Function(_$BudgetAlternativeImpl) _then)
      : super(_value, _then);

  /// Create a copy of BudgetAlternative
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemName = null,
    Object? diyOption = null,
    Object? diyCost = null,
    Object? budgetOption = null,
    Object? budgetCost = null,
    Object? premiumOption = null,
    Object? premiumCost = null,
  }) {
    return _then(_$BudgetAlternativeImpl(
      itemName: null == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String,
      diyOption: null == diyOption
          ? _value.diyOption
          : diyOption // ignore: cast_nullable_to_non_nullable
              as String,
      diyCost: null == diyCost
          ? _value.diyCost
          : diyCost // ignore: cast_nullable_to_non_nullable
              as int,
      budgetOption: null == budgetOption
          ? _value.budgetOption
          : budgetOption // ignore: cast_nullable_to_non_nullable
              as String,
      budgetCost: null == budgetCost
          ? _value.budgetCost
          : budgetCost // ignore: cast_nullable_to_non_nullable
              as int,
      premiumOption: null == premiumOption
          ? _value.premiumOption
          : premiumOption // ignore: cast_nullable_to_non_nullable
              as String,
      premiumCost: null == premiumCost
          ? _value.premiumCost
          : premiumCost // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BudgetAlternativeImpl implements _BudgetAlternative {
  const _$BudgetAlternativeImpl(
      {required this.itemName,
      required this.diyOption,
      required this.diyCost,
      required this.budgetOption,
      required this.budgetCost,
      required this.premiumOption,
      required this.premiumCost});

  factory _$BudgetAlternativeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetAlternativeImplFromJson(json);

  @override
  final String itemName;
  @override
  final String diyOption;
  @override
  final int diyCost;
  @override
  final String budgetOption;
  @override
  final int budgetCost;
  @override
  final String premiumOption;
  @override
  final int premiumCost;

  @override
  String toString() {
    return 'BudgetAlternative(itemName: $itemName, diyOption: $diyOption, diyCost: $diyCost, budgetOption: $budgetOption, budgetCost: $budgetCost, premiumOption: $premiumOption, premiumCost: $premiumCost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetAlternativeImpl &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.diyOption, diyOption) ||
                other.diyOption == diyOption) &&
            (identical(other.diyCost, diyCost) || other.diyCost == diyCost) &&
            (identical(other.budgetOption, budgetOption) ||
                other.budgetOption == budgetOption) &&
            (identical(other.budgetCost, budgetCost) ||
                other.budgetCost == budgetCost) &&
            (identical(other.premiumOption, premiumOption) ||
                other.premiumOption == premiumOption) &&
            (identical(other.premiumCost, premiumCost) ||
                other.premiumCost == premiumCost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemName, diyOption, diyCost,
      budgetOption, budgetCost, premiumOption, premiumCost);

  /// Create a copy of BudgetAlternative
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetAlternativeImplCopyWith<_$BudgetAlternativeImpl> get copyWith =>
      __$$BudgetAlternativeImplCopyWithImpl<_$BudgetAlternativeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetAlternativeImplToJson(
      this,
    );
  }
}

abstract class _BudgetAlternative implements BudgetAlternative {
  const factory _BudgetAlternative(
      {required final String itemName,
      required final String diyOption,
      required final int diyCost,
      required final String budgetOption,
      required final int budgetCost,
      required final String premiumOption,
      required final int premiumCost}) = _$BudgetAlternativeImpl;

  factory _BudgetAlternative.fromJson(Map<String, dynamic> json) =
      _$BudgetAlternativeImpl.fromJson;

  @override
  String get itemName;
  @override
  String get diyOption;
  @override
  int get diyCost;
  @override
  String get budgetOption;
  @override
  int get budgetCost;
  @override
  String get premiumOption;
  @override
  int get premiumCost;

  /// Create a copy of BudgetAlternative
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetAlternativeImplCopyWith<_$BudgetAlternativeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
