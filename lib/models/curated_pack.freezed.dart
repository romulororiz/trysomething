// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curated_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CuratedPack _$CuratedPackFromJson(Map<String, dynamic> json) {
  return _CuratedPack.fromJson(json);
}

/// @nodoc
mixin _$CuratedPack {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  List<Hobby> get hobbies => throw _privateConstructorUsedError;

  /// Serializes this CuratedPack to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CuratedPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CuratedPackCopyWith<CuratedPack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CuratedPackCopyWith<$Res> {
  factory $CuratedPackCopyWith(
          CuratedPack value, $Res Function(CuratedPack) then) =
      _$CuratedPackCopyWithImpl<$Res, CuratedPack>;
  @useResult
  $Res call({String id, String title, String icon, List<Hobby> hobbies});
}

/// @nodoc
class _$CuratedPackCopyWithImpl<$Res, $Val extends CuratedPack>
    implements $CuratedPackCopyWith<$Res> {
  _$CuratedPackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CuratedPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? icon = null,
    Object? hobbies = null,
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
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      hobbies: null == hobbies
          ? _value.hobbies
          : hobbies // ignore: cast_nullable_to_non_nullable
              as List<Hobby>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CuratedPackImplCopyWith<$Res>
    implements $CuratedPackCopyWith<$Res> {
  factory _$$CuratedPackImplCopyWith(
          _$CuratedPackImpl value, $Res Function(_$CuratedPackImpl) then) =
      __$$CuratedPackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String icon, List<Hobby> hobbies});
}

/// @nodoc
class __$$CuratedPackImplCopyWithImpl<$Res>
    extends _$CuratedPackCopyWithImpl<$Res, _$CuratedPackImpl>
    implements _$$CuratedPackImplCopyWith<$Res> {
  __$$CuratedPackImplCopyWithImpl(
      _$CuratedPackImpl _value, $Res Function(_$CuratedPackImpl) _then)
      : super(_value, _then);

  /// Create a copy of CuratedPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? icon = null,
    Object? hobbies = null,
  }) {
    return _then(_$CuratedPackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      hobbies: null == hobbies
          ? _value._hobbies
          : hobbies // ignore: cast_nullable_to_non_nullable
              as List<Hobby>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CuratedPackImpl implements _CuratedPack {
  const _$CuratedPackImpl(
      {required this.id,
      required this.title,
      required this.icon,
      required final List<Hobby> hobbies})
      : _hobbies = hobbies;

  factory _$CuratedPackImpl.fromJson(Map<String, dynamic> json) =>
      _$$CuratedPackImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String icon;
  final List<Hobby> _hobbies;
  @override
  List<Hobby> get hobbies {
    if (_hobbies is EqualUnmodifiableListView) return _hobbies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hobbies);
  }

  @override
  String toString() {
    return 'CuratedPack(id: $id, title: $title, icon: $icon, hobbies: $hobbies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CuratedPackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._hobbies, _hobbies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, icon,
      const DeepCollectionEquality().hash(_hobbies));

  /// Create a copy of CuratedPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CuratedPackImplCopyWith<_$CuratedPackImpl> get copyWith =>
      __$$CuratedPackImplCopyWithImpl<_$CuratedPackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CuratedPackImplToJson(
      this,
    );
  }
}

abstract class _CuratedPack implements CuratedPack {
  const factory _CuratedPack(
      {required final String id,
      required final String title,
      required final String icon,
      required final List<Hobby> hobbies}) = _$CuratedPackImpl;

  factory _CuratedPack.fromJson(Map<String, dynamic> json) =
      _$CuratedPackImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get icon;
  @override
  List<Hobby> get hobbies;

  /// Create a copy of CuratedPack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CuratedPackImplCopyWith<_$CuratedPackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
