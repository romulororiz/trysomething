import 'package:freezed_annotation/freezed_annotation.dart';
import 'hobby.dart';

part 'curated_pack.freezed.dart';
part 'curated_pack.g.dart';

@freezed
class CuratedPack with _$CuratedPack {
  const factory CuratedPack({
    required String id,
    required String title,
    required String icon,
    required List<Hobby> hobbies,
  }) = _CuratedPack;

  factory CuratedPack.fromJson(Map<String, dynamic> json) =>
      _$CuratedPackFromJson(json);
}
