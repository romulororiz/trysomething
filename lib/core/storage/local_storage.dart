import 'package:hive_flutter/hive_flutter.dart';

/// Hive local storage initialization and box name constants.
class LocalStorage {
  LocalStorage._();

  static const hobbyBox = 'hobbies';
  static const categoryBox = 'categories';
  static const cacheMetaBox = 'cache_meta';

  /// Call once in main() before runApp.
  static Future<void> init() async {
    await Hive.initFlutter();
  }
}
