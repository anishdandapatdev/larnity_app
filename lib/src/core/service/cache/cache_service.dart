// import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart';
// import 'package:larnity/src/core/service/cache/cache_model.dart';

// class CacheService {
//   static const String _boxName = 'app_cache';
//   Box<CacheEntry>? _box;

//   Future<void> initialize() async {
//     try {
//       await Hive.initFlutter();

//       if (!Hive.isAdapterRegistered(0)) {
//         Hive.registerAdapter(CacheEntryAdapter());
//       }

//       _box = await Hive.openBox<CacheEntry>(_boxName);

//       if (kDebugMode) {
//         print('Cache initialized with ${_box?.length ?? 0} items');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Cache initialization failed: $e');
//       }
//       rethrow;
//     }
//   }

//   // Get item from cache
//   Future<T?> get<T>(String key) async {
//     try {
//       final entry = _box?.get(key);
//       return entry?.data as T?;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Cache get error for key $key: $e');
//       }
//       return null;
//     }
//   }

//   // Put item in cache
//   Future<void> put<T>(String key, T data) async {
//     try {
//       if (_box == null) return;

//       final entry = CacheEntry(key: key, data: data);

//       await _box!.put(key, entry);
//     } catch (e) {
//       if (kDebugMode) {
//         print('Cache put error for key $key: $e');
//       }
//     }
//   }

//   // Remove specific item
//   Future<void> remove(String key) async {
//     try {
//       await _box?.delete(key);
//     } catch (e) {
//       if (kDebugMode) {
//         print('Cache remove error for key $key: $e');
//       }
//     }
//   }

//   // Clear all cache
//   Future<void> clear() async {
//     try {
//       await _box?.clear();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Cache clear error: $e');
//       }
//     }
//   }

//   // Check if key exists
//   Future<bool> contains(String key) async {
//     try {
//       return _box?.containsKey(key) ?? false;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Get cache size
//   int get size => _box?.length ?? 0;

//   // Get all keys
//   List<String> get keys {
//     return _box?.keys.cast<String>().toList() ?? [];
//   }

//   // Dispose resources
//   Future<void> dispose() async {
//     try {
//       await _box?.close();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Cache dispose error: $e');
//       }
//     }
//   }
// }
