import 'package:hive_flutter/hive_flutter.dart';
import 'local_storage.dart';

/// Hive-based cache with TTL support.
/// Stores JSON strings keyed by cache key, with timestamp tracking.
class CacheManager {
  static const Duration defaultTtl = Duration(hours: 1);

  /// Bump this when the API response shape changes (e.g. new fields added).
  /// All cached entries from a previous version are treated as expired.
  static const int _cacheVersion = 2; // v2: added coachTip + completionMessage

  static late Box<String> _dataBox;
  static late Box<int> _metaBox;
  static bool _initialized = false;

  /// Open Hive boxes. Called once from [LocalStorage.init].
  static Future<void> init() async {
    if (_initialized) return;
    _dataBox = await Hive.openBox<String>(LocalStorage.hobbyBox);
    _metaBox = await Hive.openBox<int>(LocalStorage.cacheMetaBox);
    _initialized = true;

    // Clear all caches if version changed
    final storedVersion = _metaBox.get('__cache_version__') ?? 0;
    if (storedVersion < _cacheVersion) {
      await _dataBox.clear();
      await _metaBox.clear();
      await _metaBox.put('__cache_version__', _cacheVersion);
    }
  }

  /// Returns cached JSON string, or null if missing/expired.
  static String? get(String key, {Duration ttl = defaultTtl}) {
    if (!_initialized) return null;
    final timestamp = _metaBox.get(key);
    if (timestamp == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age > ttl.inMilliseconds) return null; // expired

    return _dataBox.get(key);
  }

  /// Returns cached JSON string even if expired (for fallback on API error).
  static String? getStale(String key) {
    if (!_initialized) return null;
    return _dataBox.get(key);
  }

  /// Store a JSON string with current timestamp.
  static Future<void> put(String key, String jsonString) async {
    if (!_initialized) return;
    await _dataBox.put(key, jsonString);
    await _metaBox.put(key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Remove a cached entry so the next [get] returns null.
  /// The data is kept for [getStale] fallback until overwritten.
  static Future<void> invalidate(String key) async {
    if (!_initialized) return;
    await _metaBox.delete(key);
  }
}
