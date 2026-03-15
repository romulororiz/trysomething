// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hobby.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Hobby _$HobbyFromJson(Map<String, dynamic> json) {
  return _Hobby.fromJson(json);
}

/// @nodoc
mixin _$Hobby {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get hook => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get costText => throw _privateConstructorUsedError;
  String get timeText => throw _privateConstructorUsedError;
  String get difficultyText => throw _privateConstructorUsedError;
  String get whyLove => throw _privateConstructorUsedError;
  String get difficultyExplain => throw _privateConstructorUsedError;
  List<KitItem> get starterKit => throw _privateConstructorUsedError;
  List<String> get pitfalls => throw _privateConstructorUsedError;
  List<String> get quittingReasons => throw _privateConstructorUsedError;
  List<RoadmapStep> get roadmapSteps => throw _privateConstructorUsedError;

  /// Serializes this Hobby to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HobbyCopyWith<Hobby> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HobbyCopyWith<$Res> {
  factory $HobbyCopyWith(Hobby value, $Res Function(Hobby) then) =
      _$HobbyCopyWithImpl<$Res, Hobby>;
  @useResult
  $Res call(
      {String id,
      String title,
      String hook,
      String category,
      String imageUrl,
      List<String> tags,
      String costText,
      String timeText,
      String difficultyText,
      String whyLove,
      String difficultyExplain,
      List<KitItem> starterKit,
      List<String> pitfalls,
      List<String> quittingReasons,
      List<RoadmapStep> roadmapSteps});
}

/// @nodoc
class _$HobbyCopyWithImpl<$Res, $Val extends Hobby>
    implements $HobbyCopyWith<$Res> {
  _$HobbyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? hook = null,
    Object? category = null,
    Object? imageUrl = null,
    Object? tags = null,
    Object? costText = null,
    Object? timeText = null,
    Object? difficultyText = null,
    Object? whyLove = null,
    Object? difficultyExplain = null,
    Object? starterKit = null,
    Object? pitfalls = null,
    Object? quittingReasons = null,
    Object? roadmapSteps = null,
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
      hook: null == hook
          ? _value.hook
          : hook // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      costText: null == costText
          ? _value.costText
          : costText // ignore: cast_nullable_to_non_nullable
              as String,
      timeText: null == timeText
          ? _value.timeText
          : timeText // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyText: null == difficultyText
          ? _value.difficultyText
          : difficultyText // ignore: cast_nullable_to_non_nullable
              as String,
      whyLove: null == whyLove
          ? _value.whyLove
          : whyLove // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyExplain: null == difficultyExplain
          ? _value.difficultyExplain
          : difficultyExplain // ignore: cast_nullable_to_non_nullable
              as String,
      starterKit: null == starterKit
          ? _value.starterKit
          : starterKit // ignore: cast_nullable_to_non_nullable
              as List<KitItem>,
      pitfalls: null == pitfalls
          ? _value.pitfalls
          : pitfalls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      quittingReasons: null == quittingReasons
          ? _value.quittingReasons
          : quittingReasons // ignore: cast_nullable_to_non_nullable
              as List<String>,
      roadmapSteps: null == roadmapSteps
          ? _value.roadmapSteps
          : roadmapSteps // ignore: cast_nullable_to_non_nullable
              as List<RoadmapStep>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HobbyImplCopyWith<$Res> implements $HobbyCopyWith<$Res> {
  factory _$$HobbyImplCopyWith(
          _$HobbyImpl value, $Res Function(_$HobbyImpl) then) =
      __$$HobbyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String hook,
      String category,
      String imageUrl,
      List<String> tags,
      String costText,
      String timeText,
      String difficultyText,
      String whyLove,
      String difficultyExplain,
      List<KitItem> starterKit,
      List<String> pitfalls,
      List<String> quittingReasons,
      List<RoadmapStep> roadmapSteps});
}

/// @nodoc
class __$$HobbyImplCopyWithImpl<$Res>
    extends _$HobbyCopyWithImpl<$Res, _$HobbyImpl>
    implements _$$HobbyImplCopyWith<$Res> {
  __$$HobbyImplCopyWithImpl(
      _$HobbyImpl _value, $Res Function(_$HobbyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? hook = null,
    Object? category = null,
    Object? imageUrl = null,
    Object? tags = null,
    Object? costText = null,
    Object? timeText = null,
    Object? difficultyText = null,
    Object? whyLove = null,
    Object? difficultyExplain = null,
    Object? starterKit = null,
    Object? pitfalls = null,
    Object? quittingReasons = null,
    Object? roadmapSteps = null,
  }) {
    return _then(_$HobbyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      hook: null == hook
          ? _value.hook
          : hook // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      costText: null == costText
          ? _value.costText
          : costText // ignore: cast_nullable_to_non_nullable
              as String,
      timeText: null == timeText
          ? _value.timeText
          : timeText // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyText: null == difficultyText
          ? _value.difficultyText
          : difficultyText // ignore: cast_nullable_to_non_nullable
              as String,
      whyLove: null == whyLove
          ? _value.whyLove
          : whyLove // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyExplain: null == difficultyExplain
          ? _value.difficultyExplain
          : difficultyExplain // ignore: cast_nullable_to_non_nullable
              as String,
      starterKit: null == starterKit
          ? _value._starterKit
          : starterKit // ignore: cast_nullable_to_non_nullable
              as List<KitItem>,
      pitfalls: null == pitfalls
          ? _value._pitfalls
          : pitfalls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      quittingReasons: null == quittingReasons
          ? _value._quittingReasons
          : quittingReasons // ignore: cast_nullable_to_non_nullable
              as List<String>,
      roadmapSteps: null == roadmapSteps
          ? _value._roadmapSteps
          : roadmapSteps // ignore: cast_nullable_to_non_nullable
              as List<RoadmapStep>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HobbyImpl implements _Hobby {
  const _$HobbyImpl(
      {required this.id,
      required this.title,
      required this.hook,
      required this.category,
      required this.imageUrl,
      required final List<String> tags,
      required this.costText,
      required this.timeText,
      required this.difficultyText,
      required this.whyLove,
      required this.difficultyExplain,
      required final List<KitItem> starterKit,
      required final List<String> pitfalls,
      final List<String> quittingReasons = const [],
      required final List<RoadmapStep> roadmapSteps})
      : _tags = tags,
        _starterKit = starterKit,
        _pitfalls = pitfalls,
        _quittingReasons = quittingReasons,
        _roadmapSteps = roadmapSteps;

  factory _$HobbyImpl.fromJson(Map<String, dynamic> json) =>
      _$$HobbyImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String hook;
  @override
  final String category;
  @override
  final String imageUrl;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String costText;
  @override
  final String timeText;
  @override
  final String difficultyText;
  @override
  final String whyLove;
  @override
  final String difficultyExplain;
  final List<KitItem> _starterKit;
  @override
  List<KitItem> get starterKit {
    if (_starterKit is EqualUnmodifiableListView) return _starterKit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_starterKit);
  }

  final List<String> _pitfalls;
  @override
  List<String> get pitfalls {
    if (_pitfalls is EqualUnmodifiableListView) return _pitfalls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pitfalls);
  }

  final List<String> _quittingReasons;
  @override
  @JsonKey()
  List<String> get quittingReasons {
    if (_quittingReasons is EqualUnmodifiableListView) return _quittingReasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quittingReasons);
  }

  final List<RoadmapStep> _roadmapSteps;
  @override
  List<RoadmapStep> get roadmapSteps {
    if (_roadmapSteps is EqualUnmodifiableListView) return _roadmapSteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roadmapSteps);
  }

  @override
  String toString() {
    return 'Hobby(id: $id, title: $title, hook: $hook, category: $category, imageUrl: $imageUrl, tags: $tags, costText: $costText, timeText: $timeText, difficultyText: $difficultyText, whyLove: $whyLove, difficultyExplain: $difficultyExplain, starterKit: $starterKit, pitfalls: $pitfalls, quittingReasons: $quittingReasons, roadmapSteps: $roadmapSteps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HobbyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.hook, hook) || other.hook == hook) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.costText, costText) ||
                other.costText == costText) &&
            (identical(other.timeText, timeText) ||
                other.timeText == timeText) &&
            (identical(other.difficultyText, difficultyText) ||
                other.difficultyText == difficultyText) &&
            (identical(other.whyLove, whyLove) || other.whyLove == whyLove) &&
            (identical(other.difficultyExplain, difficultyExplain) ||
                other.difficultyExplain == difficultyExplain) &&
            const DeepCollectionEquality()
                .equals(other._starterKit, _starterKit) &&
            const DeepCollectionEquality().equals(other._pitfalls, _pitfalls) &&
            const DeepCollectionEquality()
                .equals(other._quittingReasons, _quittingReasons) &&
            const DeepCollectionEquality()
                .equals(other._roadmapSteps, _roadmapSteps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      hook,
      category,
      imageUrl,
      const DeepCollectionEquality().hash(_tags),
      costText,
      timeText,
      difficultyText,
      whyLove,
      difficultyExplain,
      const DeepCollectionEquality().hash(_starterKit),
      const DeepCollectionEquality().hash(_pitfalls),
      const DeepCollectionEquality().hash(_quittingReasons),
      const DeepCollectionEquality().hash(_roadmapSteps));

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HobbyImplCopyWith<_$HobbyImpl> get copyWith =>
      __$$HobbyImplCopyWithImpl<_$HobbyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HobbyImplToJson(
      this,
    );
  }
}

abstract class _Hobby implements Hobby {
  const factory _Hobby(
      {required final String id,
      required final String title,
      required final String hook,
      required final String category,
      required final String imageUrl,
      required final List<String> tags,
      required final String costText,
      required final String timeText,
      required final String difficultyText,
      required final String whyLove,
      required final String difficultyExplain,
      required final List<KitItem> starterKit,
      required final List<String> pitfalls,
      final List<String> quittingReasons,
      required final List<RoadmapStep> roadmapSteps}) = _$HobbyImpl;

  factory _Hobby.fromJson(Map<String, dynamic> json) = _$HobbyImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get hook;
  @override
  String get category;
  @override
  String get imageUrl;
  @override
  List<String> get tags;
  @override
  String get costText;
  @override
  String get timeText;
  @override
  String get difficultyText;
  @override
  String get whyLove;
  @override
  String get difficultyExplain;
  @override
  List<KitItem> get starterKit;
  @override
  List<String> get pitfalls;
  @override
  List<String> get quittingReasons;
  @override
  List<RoadmapStep> get roadmapSteps;

  /// Create a copy of Hobby
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HobbyImplCopyWith<_$HobbyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KitItem _$KitItemFromJson(Map<String, dynamic> json) {
  return _KitItem.fromJson(json);
}

/// @nodoc
mixin _$KitItem {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get cost => throw _privateConstructorUsedError;
  bool get isOptional => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get affiliateUrl => throw _privateConstructorUsedError;
  String? get affiliateSource => throw _privateConstructorUsedError;

  /// Serializes this KitItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KitItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KitItemCopyWith<KitItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KitItemCopyWith<$Res> {
  factory $KitItemCopyWith(KitItem value, $Res Function(KitItem) then) =
      _$KitItemCopyWithImpl<$Res, KitItem>;
  @useResult
  $Res call(
      {String name,
      String description,
      int cost,
      bool isOptional,
      String? imageUrl,
      String? affiliateUrl,
      String? affiliateSource});
}

/// @nodoc
class _$KitItemCopyWithImpl<$Res, $Val extends KitItem>
    implements $KitItemCopyWith<$Res> {
  _$KitItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KitItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? cost = null,
    Object? isOptional = null,
    Object? imageUrl = freezed,
    Object? affiliateUrl = freezed,
    Object? affiliateSource = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int,
      isOptional: null == isOptional
          ? _value.isOptional
          : isOptional // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      affiliateUrl: freezed == affiliateUrl
          ? _value.affiliateUrl
          : affiliateUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      affiliateSource: freezed == affiliateSource
          ? _value.affiliateSource
          : affiliateSource // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KitItemImplCopyWith<$Res> implements $KitItemCopyWith<$Res> {
  factory _$$KitItemImplCopyWith(
          _$KitItemImpl value, $Res Function(_$KitItemImpl) then) =
      __$$KitItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String description,
      int cost,
      bool isOptional,
      String? imageUrl,
      String? affiliateUrl,
      String? affiliateSource});
}

/// @nodoc
class __$$KitItemImplCopyWithImpl<$Res>
    extends _$KitItemCopyWithImpl<$Res, _$KitItemImpl>
    implements _$$KitItemImplCopyWith<$Res> {
  __$$KitItemImplCopyWithImpl(
      _$KitItemImpl _value, $Res Function(_$KitItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of KitItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? cost = null,
    Object? isOptional = null,
    Object? imageUrl = freezed,
    Object? affiliateUrl = freezed,
    Object? affiliateSource = freezed,
  }) {
    return _then(_$KitItemImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int,
      isOptional: null == isOptional
          ? _value.isOptional
          : isOptional // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      affiliateUrl: freezed == affiliateUrl
          ? _value.affiliateUrl
          : affiliateUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      affiliateSource: freezed == affiliateSource
          ? _value.affiliateSource
          : affiliateSource // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KitItemImpl implements _KitItem {
  const _$KitItemImpl(
      {required this.name,
      required this.description,
      required this.cost,
      this.isOptional = false,
      this.imageUrl,
      this.affiliateUrl,
      this.affiliateSource});

  factory _$KitItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$KitItemImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  @override
  final int cost;
  @override
  @JsonKey()
  final bool isOptional;
  @override
  final String? imageUrl;
  @override
  final String? affiliateUrl;
  @override
  final String? affiliateSource;

  @override
  String toString() {
    return 'KitItem(name: $name, description: $description, cost: $cost, isOptional: $isOptional, imageUrl: $imageUrl, affiliateUrl: $affiliateUrl, affiliateSource: $affiliateSource)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KitItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.isOptional, isOptional) ||
                other.isOptional == isOptional) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.affiliateUrl, affiliateUrl) ||
                other.affiliateUrl == affiliateUrl) &&
            (identical(other.affiliateSource, affiliateSource) ||
                other.affiliateSource == affiliateSource));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, description, cost,
      isOptional, imageUrl, affiliateUrl, affiliateSource);

  /// Create a copy of KitItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KitItemImplCopyWith<_$KitItemImpl> get copyWith =>
      __$$KitItemImplCopyWithImpl<_$KitItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KitItemImplToJson(
      this,
    );
  }
}

abstract class _KitItem implements KitItem {
  const factory _KitItem(
      {required final String name,
      required final String description,
      required final int cost,
      final bool isOptional,
      final String? imageUrl,
      final String? affiliateUrl,
      final String? affiliateSource}) = _$KitItemImpl;

  factory _KitItem.fromJson(Map<String, dynamic> json) = _$KitItemImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  int get cost;
  @override
  bool get isOptional;
  @override
  String? get imageUrl;
  @override
  String? get affiliateUrl;
  @override
  String? get affiliateSource;

  /// Create a copy of KitItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KitItemImplCopyWith<_$KitItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoadmapStep _$RoadmapStepFromJson(Map<String, dynamic> json) {
  return _RoadmapStep.fromJson(json);
}

/// @nodoc
mixin _$RoadmapStep {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get estimatedMinutes => throw _privateConstructorUsedError;
  String? get milestone => throw _privateConstructorUsedError;
  String? get coachTip => throw _privateConstructorUsedError;
  String? get completionMessage => throw _privateConstructorUsedError;
  CompletionMode? get completionMode => throw _privateConstructorUsedError;

  /// Serializes this RoadmapStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoadmapStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoadmapStepCopyWith<RoadmapStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoadmapStepCopyWith<$Res> {
  factory $RoadmapStepCopyWith(
          RoadmapStep value, $Res Function(RoadmapStep) then) =
      _$RoadmapStepCopyWithImpl<$Res, RoadmapStep>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int estimatedMinutes,
      String? milestone,
      String? coachTip,
      String? completionMessage,
      CompletionMode? completionMode});
}

/// @nodoc
class _$RoadmapStepCopyWithImpl<$Res, $Val extends RoadmapStep>
    implements $RoadmapStepCopyWith<$Res> {
  _$RoadmapStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoadmapStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? estimatedMinutes = null,
    Object? milestone = freezed,
    Object? coachTip = freezed,
    Object? completionMessage = freezed,
    Object? completionMode = freezed,
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
      estimatedMinutes: null == estimatedMinutes
          ? _value.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      milestone: freezed == milestone
          ? _value.milestone
          : milestone // ignore: cast_nullable_to_non_nullable
              as String?,
      coachTip: freezed == coachTip
          ? _value.coachTip
          : coachTip // ignore: cast_nullable_to_non_nullable
              as String?,
      completionMessage: freezed == completionMessage
          ? _value.completionMessage
          : completionMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      completionMode: freezed == completionMode
          ? _value.completionMode
          : completionMode // ignore: cast_nullable_to_non_nullable
              as CompletionMode?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoadmapStepImplCopyWith<$Res>
    implements $RoadmapStepCopyWith<$Res> {
  factory _$$RoadmapStepImplCopyWith(
          _$RoadmapStepImpl value, $Res Function(_$RoadmapStepImpl) then) =
      __$$RoadmapStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int estimatedMinutes,
      String? milestone,
      String? coachTip,
      String? completionMessage,
      CompletionMode? completionMode});
}

/// @nodoc
class __$$RoadmapStepImplCopyWithImpl<$Res>
    extends _$RoadmapStepCopyWithImpl<$Res, _$RoadmapStepImpl>
    implements _$$RoadmapStepImplCopyWith<$Res> {
  __$$RoadmapStepImplCopyWithImpl(
      _$RoadmapStepImpl _value, $Res Function(_$RoadmapStepImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoadmapStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? estimatedMinutes = null,
    Object? milestone = freezed,
    Object? coachTip = freezed,
    Object? completionMessage = freezed,
    Object? completionMode = freezed,
  }) {
    return _then(_$RoadmapStepImpl(
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
      estimatedMinutes: null == estimatedMinutes
          ? _value.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      milestone: freezed == milestone
          ? _value.milestone
          : milestone // ignore: cast_nullable_to_non_nullable
              as String?,
      coachTip: freezed == coachTip
          ? _value.coachTip
          : coachTip // ignore: cast_nullable_to_non_nullable
              as String?,
      completionMessage: freezed == completionMessage
          ? _value.completionMessage
          : completionMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      completionMode: freezed == completionMode
          ? _value.completionMode
          : completionMode // ignore: cast_nullable_to_non_nullable
              as CompletionMode?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoadmapStepImpl extends _RoadmapStep {
  const _$RoadmapStepImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.estimatedMinutes,
      this.milestone,
      this.coachTip,
      this.completionMessage,
      this.completionMode})
      : super._();

  factory _$RoadmapStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoadmapStepImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final int estimatedMinutes;
  @override
  final String? milestone;
  @override
  final String? coachTip;
  @override
  final String? completionMessage;
  @override
  final CompletionMode? completionMode;

  @override
  String toString() {
    return 'RoadmapStep(id: $id, title: $title, description: $description, estimatedMinutes: $estimatedMinutes, milestone: $milestone, coachTip: $coachTip, completionMessage: $completionMessage, completionMode: $completionMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoadmapStepImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.milestone, milestone) ||
                other.milestone == milestone) &&
            (identical(other.coachTip, coachTip) ||
                other.coachTip == coachTip) &&
            (identical(other.completionMessage, completionMessage) ||
                other.completionMessage == completionMessage) &&
            (identical(other.completionMode, completionMode) ||
                other.completionMode == completionMode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description,
      estimatedMinutes, milestone, coachTip, completionMessage, completionMode);

  /// Create a copy of RoadmapStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoadmapStepImplCopyWith<_$RoadmapStepImpl> get copyWith =>
      __$$RoadmapStepImplCopyWithImpl<_$RoadmapStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoadmapStepImplToJson(
      this,
    );
  }
}

abstract class _RoadmapStep extends RoadmapStep {
  const factory _RoadmapStep(
      {required final String id,
      required final String title,
      required final String description,
      required final int estimatedMinutes,
      final String? milestone,
      final String? coachTip,
      final String? completionMessage,
      final CompletionMode? completionMode}) = _$RoadmapStepImpl;
  const _RoadmapStep._() : super._();

  factory _RoadmapStep.fromJson(Map<String, dynamic> json) =
      _$RoadmapStepImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  int get estimatedMinutes;
  @override
  String? get milestone;
  @override
  String? get coachTip;
  @override
  String? get completionMessage;
  @override
  CompletionMode? get completionMode;

  /// Create a copy of RoadmapStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoadmapStepImplCopyWith<_$RoadmapStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HobbyCategory _$HobbyCategoryFromJson(Map<String, dynamic> json) {
  return _HobbyCategory.fromJson(json);
}

/// @nodoc
mixin _$HobbyCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this HobbyCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HobbyCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HobbyCategoryCopyWith<HobbyCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HobbyCategoryCopyWith<$Res> {
  factory $HobbyCategoryCopyWith(
          HobbyCategory value, $Res Function(HobbyCategory) then) =
      _$HobbyCategoryCopyWithImpl<$Res, HobbyCategory>;
  @useResult
  $Res call({String id, String name, int count, String imageUrl});
}

/// @nodoc
class _$HobbyCategoryCopyWithImpl<$Res, $Val extends HobbyCategory>
    implements $HobbyCategoryCopyWith<$Res> {
  _$HobbyCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HobbyCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? count = null,
    Object? imageUrl = null,
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
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HobbyCategoryImplCopyWith<$Res>
    implements $HobbyCategoryCopyWith<$Res> {
  factory _$$HobbyCategoryImplCopyWith(
          _$HobbyCategoryImpl value, $Res Function(_$HobbyCategoryImpl) then) =
      __$$HobbyCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int count, String imageUrl});
}

/// @nodoc
class __$$HobbyCategoryImplCopyWithImpl<$Res>
    extends _$HobbyCategoryCopyWithImpl<$Res, _$HobbyCategoryImpl>
    implements _$$HobbyCategoryImplCopyWith<$Res> {
  __$$HobbyCategoryImplCopyWithImpl(
      _$HobbyCategoryImpl _value, $Res Function(_$HobbyCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of HobbyCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? count = null,
    Object? imageUrl = null,
  }) {
    return _then(_$HobbyCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HobbyCategoryImpl implements _HobbyCategory {
  const _$HobbyCategoryImpl(
      {required this.id,
      required this.name,
      required this.count,
      required this.imageUrl});

  factory _$HobbyCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$HobbyCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int count;
  @override
  final String imageUrl;

  @override
  String toString() {
    return 'HobbyCategory(id: $id, name: $name, count: $count, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HobbyCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, count, imageUrl);

  /// Create a copy of HobbyCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HobbyCategoryImplCopyWith<_$HobbyCategoryImpl> get copyWith =>
      __$$HobbyCategoryImplCopyWithImpl<_$HobbyCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HobbyCategoryImplToJson(
      this,
    );
  }
}

abstract class _HobbyCategory implements HobbyCategory {
  const factory _HobbyCategory(
      {required final String id,
      required final String name,
      required final int count,
      required final String imageUrl}) = _$HobbyCategoryImpl;

  factory _HobbyCategory.fromJson(Map<String, dynamic> json) =
      _$HobbyCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get count;
  @override
  String get imageUrl;

  /// Create a copy of HobbyCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HobbyCategoryImplCopyWith<_$HobbyCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserHobby _$UserHobbyFromJson(Map<String, dynamic> json) {
  return _UserHobby.fromJson(json);
}

/// @nodoc
mixin _$UserHobby {
  String get hobbyId => throw _privateConstructorUsedError;
  HobbyStatus get status => throw _privateConstructorUsedError;
  @SetStringConverter()
  Set<String> get completedStepIds => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get lastActivityAt => throw _privateConstructorUsedError;
  int get streakDays => throw _privateConstructorUsedError;

  /// Serializes this UserHobby to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserHobby
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserHobbyCopyWith<UserHobby> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserHobbyCopyWith<$Res> {
  factory $UserHobbyCopyWith(UserHobby value, $Res Function(UserHobby) then) =
      _$UserHobbyCopyWithImpl<$Res, UserHobby>;
  @useResult
  $Res call(
      {String hobbyId,
      HobbyStatus status,
      @SetStringConverter() Set<String> completedStepIds,
      DateTime? startedAt,
      DateTime? lastActivityAt,
      int streakDays});
}

/// @nodoc
class _$UserHobbyCopyWithImpl<$Res, $Val extends UserHobby>
    implements $UserHobbyCopyWith<$Res> {
  _$UserHobbyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserHobby
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hobbyId = null,
    Object? status = null,
    Object? completedStepIds = null,
    Object? startedAt = freezed,
    Object? lastActivityAt = freezed,
    Object? streakDays = null,
  }) {
    return _then(_value.copyWith(
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HobbyStatus,
      completedStepIds: null == completedStepIds
          ? _value.completedStepIds
          : completedStepIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActivityAt: freezed == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      streakDays: null == streakDays
          ? _value.streakDays
          : streakDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserHobbyImplCopyWith<$Res>
    implements $UserHobbyCopyWith<$Res> {
  factory _$$UserHobbyImplCopyWith(
          _$UserHobbyImpl value, $Res Function(_$UserHobbyImpl) then) =
      __$$UserHobbyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String hobbyId,
      HobbyStatus status,
      @SetStringConverter() Set<String> completedStepIds,
      DateTime? startedAt,
      DateTime? lastActivityAt,
      int streakDays});
}

/// @nodoc
class __$$UserHobbyImplCopyWithImpl<$Res>
    extends _$UserHobbyCopyWithImpl<$Res, _$UserHobbyImpl>
    implements _$$UserHobbyImplCopyWith<$Res> {
  __$$UserHobbyImplCopyWithImpl(
      _$UserHobbyImpl _value, $Res Function(_$UserHobbyImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserHobby
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hobbyId = null,
    Object? status = null,
    Object? completedStepIds = null,
    Object? startedAt = freezed,
    Object? lastActivityAt = freezed,
    Object? streakDays = null,
  }) {
    return _then(_$UserHobbyImpl(
      hobbyId: null == hobbyId
          ? _value.hobbyId
          : hobbyId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HobbyStatus,
      completedStepIds: null == completedStepIds
          ? _value._completedStepIds
          : completedStepIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActivityAt: freezed == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      streakDays: null == streakDays
          ? _value.streakDays
          : streakDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserHobbyImpl extends _UserHobby {
  const _$UserHobbyImpl(
      {required this.hobbyId,
      required this.status,
      @SetStringConverter()
      final Set<String> completedStepIds = const <String>{},
      this.startedAt,
      this.lastActivityAt,
      this.streakDays = 0})
      : _completedStepIds = completedStepIds,
        super._();

  factory _$UserHobbyImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserHobbyImplFromJson(json);

  @override
  final String hobbyId;
  @override
  final HobbyStatus status;
  final Set<String> _completedStepIds;
  @override
  @JsonKey()
  @SetStringConverter()
  Set<String> get completedStepIds {
    if (_completedStepIds is EqualUnmodifiableSetView) return _completedStepIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_completedStepIds);
  }

  @override
  final DateTime? startedAt;
  @override
  final DateTime? lastActivityAt;
  @override
  @JsonKey()
  final int streakDays;

  @override
  String toString() {
    return 'UserHobby(hobbyId: $hobbyId, status: $status, completedStepIds: $completedStepIds, startedAt: $startedAt, lastActivityAt: $lastActivityAt, streakDays: $streakDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserHobbyImpl &&
            (identical(other.hobbyId, hobbyId) || other.hobbyId == hobbyId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._completedStepIds, _completedStepIds) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt) &&
            (identical(other.streakDays, streakDays) ||
                other.streakDays == streakDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      hobbyId,
      status,
      const DeepCollectionEquality().hash(_completedStepIds),
      startedAt,
      lastActivityAt,
      streakDays);

  /// Create a copy of UserHobby
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserHobbyImplCopyWith<_$UserHobbyImpl> get copyWith =>
      __$$UserHobbyImplCopyWithImpl<_$UserHobbyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserHobbyImplToJson(
      this,
    );
  }
}

abstract class _UserHobby extends UserHobby {
  const factory _UserHobby(
      {required final String hobbyId,
      required final HobbyStatus status,
      @SetStringConverter() final Set<String> completedStepIds,
      final DateTime? startedAt,
      final DateTime? lastActivityAt,
      final int streakDays}) = _$UserHobbyImpl;
  const _UserHobby._() : super._();

  factory _UserHobby.fromJson(Map<String, dynamic> json) =
      _$UserHobbyImpl.fromJson;

  @override
  String get hobbyId;
  @override
  HobbyStatus get status;
  @override
  @SetStringConverter()
  Set<String> get completedStepIds;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get lastActivityAt;
  @override
  int get streakDays;

  /// Create a copy of UserHobby
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserHobbyImplCopyWith<_$UserHobbyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  int get hoursPerWeek => throw _privateConstructorUsedError;
  int get budgetLevel => throw _privateConstructorUsedError;
  bool get preferSocial => throw _privateConstructorUsedError;
  @SetStringConverter()
  Set<String> get vibes => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {int hoursPerWeek,
      int budgetLevel,
      bool preferSocial,
      @SetStringConverter() Set<String> vibes});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hoursPerWeek = null,
    Object? budgetLevel = null,
    Object? preferSocial = null,
    Object? vibes = null,
  }) {
    return _then(_value.copyWith(
      hoursPerWeek: null == hoursPerWeek
          ? _value.hoursPerWeek
          : hoursPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      budgetLevel: null == budgetLevel
          ? _value.budgetLevel
          : budgetLevel // ignore: cast_nullable_to_non_nullable
              as int,
      preferSocial: null == preferSocial
          ? _value.preferSocial
          : preferSocial // ignore: cast_nullable_to_non_nullable
              as bool,
      vibes: null == vibes
          ? _value.vibes
          : vibes // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int hoursPerWeek,
      int budgetLevel,
      bool preferSocial,
      @SetStringConverter() Set<String> vibes});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hoursPerWeek = null,
    Object? budgetLevel = null,
    Object? preferSocial = null,
    Object? vibes = null,
  }) {
    return _then(_$UserPreferencesImpl(
      hoursPerWeek: null == hoursPerWeek
          ? _value.hoursPerWeek
          : hoursPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      budgetLevel: null == budgetLevel
          ? _value.budgetLevel
          : budgetLevel // ignore: cast_nullable_to_non_nullable
              as int,
      preferSocial: null == preferSocial
          ? _value.preferSocial
          : preferSocial // ignore: cast_nullable_to_non_nullable
              as bool,
      vibes: null == vibes
          ? _value._vibes
          : vibes // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {this.hoursPerWeek = 3,
      this.budgetLevel = 1,
      this.preferSocial = false,
      @SetStringConverter() final Set<String> vibes = const <String>{}})
      : _vibes = vibes;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final int hoursPerWeek;
  @override
  @JsonKey()
  final int budgetLevel;
  @override
  @JsonKey()
  final bool preferSocial;
  final Set<String> _vibes;
  @override
  @JsonKey()
  @SetStringConverter()
  Set<String> get vibes {
    if (_vibes is EqualUnmodifiableSetView) return _vibes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_vibes);
  }

  @override
  String toString() {
    return 'UserPreferences(hoursPerWeek: $hoursPerWeek, budgetLevel: $budgetLevel, preferSocial: $preferSocial, vibes: $vibes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.hoursPerWeek, hoursPerWeek) ||
                other.hoursPerWeek == hoursPerWeek) &&
            (identical(other.budgetLevel, budgetLevel) ||
                other.budgetLevel == budgetLevel) &&
            (identical(other.preferSocial, preferSocial) ||
                other.preferSocial == preferSocial) &&
            const DeepCollectionEquality().equals(other._vibes, _vibes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hoursPerWeek, budgetLevel,
      preferSocial, const DeepCollectionEquality().hash(_vibes));

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
      {final int hoursPerWeek,
      final int budgetLevel,
      final bool preferSocial,
      @SetStringConverter() final Set<String> vibes}) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  int get hoursPerWeek;
  @override
  int get budgetLevel;
  @override
  bool get preferSocial;
  @override
  @SetStringConverter()
  Set<String> get vibes;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
