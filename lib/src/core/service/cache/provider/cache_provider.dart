// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:flutter_riverpod/misc.dart';
// import 'package:larnity/src/core/service/cache/cache_service.dart';

// // Cache service provider
// final cacheServiceProvider = Provider<CacheService>((ref) {
//   final service = CacheService();
//   // Dispose when provider is disposed
//   ref.onDispose(() => service.dispose());
//   return service;
// });

// // Cache initialization provider
// final cacheInitProvider = FutureProvider<void>((ref) async {
//   final cacheService = ref.read(cacheServiceProvider);
//   await cacheService.initialize();
// });

// // Generic cache data provider
// final cacheDataProvider = FutureProviderFamily<dynamic, String>((
//   ref,
//   key,
// ) async {
//   final cacheService = ref.read(cacheServiceProvider);
//   return await cacheService.get(key);
// });

// // Cache state notifier for reactive operations
// class CacheNotifier extends StateNotifier<AsyncValue<String?>> {
//   final CacheService _cacheService;
//   final Ref _ref;

//   CacheNotifier(this._cacheService, this._ref)
//     : super(const AsyncValue.data(null));

//   // Get data and update state
//   Future<T?> get<T>(String key) async {
//     state = const AsyncValue.loading();
//     try {
//       final data = await _cacheService.get<T>(key);
//       state = AsyncValue.data(data?.toString());
//       return data;
//     } catch (error, stackTrace) {
//       state = AsyncValue.error(error, stackTrace);
//       return null;
//     }
//   }

//   // Put data
//   Future<void> put<T>(String key, T data) async {
//     state = const AsyncValue.loading();
//     try {
//       await _cacheService.put(key, data);
//       state = const AsyncValue.data('Item cached successfully');
//       // Invalidate the specific cache data provider to refresh it
//       _ref.invalidate(cacheDataProvider(key));
//     } catch (error, stackTrace) {
//       state = AsyncValue.error(error, stackTrace);
//     }
//   }

//   // Remove data
//   Future<void> remove(String key) async {
//     state = const AsyncValue.loading();
//     try {
//       await _cacheService.remove(key);
//       state = const AsyncValue.data('Item removed successfully');
//       // Invalidate the specific cache data provider
//       _ref.invalidate(cacheDataProvider(key));
//     } catch (error, stackTrace) {
//       state = AsyncValue.error(error, stackTrace);
//     }
//   }

//   // Clear all cache
//   Future<void> clear() async {
//     state = const AsyncValue.loading();
//     try {
//       await _cacheService.clear();
//       state = const AsyncValue.data('Cache cleared successfully');
//       // Invalidate all cache data providers
//       _ref.invalidate(cacheDataProvider);
//     } catch (error, stackTrace) {
//       state = AsyncValue.error(error, stackTrace);
//     }
//   }
// }

// // Cache notifier provider
// final cacheNotifierProvider =
//     StateNotifierProvider<CacheNotifier, AsyncValue<String?>>((ref) {
//       final cacheService = ref.read(cacheServiceProvider);
//       return CacheNotifier(cacheService, ref);
//     });

// // Convenience providers for common operations
// final userDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
//   final cacheService = ref.read(cacheServiceProvider);
//   return await cacheService.get<Map<String, dynamic>>('user_data');
// });

// final settingsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
//   final cacheService = ref.read(cacheServiceProvider);
//   return await cacheService.get<Map<String, dynamic>>('settings');
// });
