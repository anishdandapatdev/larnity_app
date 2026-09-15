// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../config/supabase_config.dart';

// // Supabase client provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// // Auth provider - provides current user session
// final authStateProvider = StreamProvider<AuthState>((ref) {
//   final client = ref.watch(supabaseClientProvider);
//   return client.auth.onAuthStateChange;
// });

// // Current user provider
// final currentUserProvider = Provider<User?>((ref) {
//   final authState = ref.watch(authStateProvider);
//   return authState.when(
//     data: (auth) => auth.session?.user,
//     loading: () => null,
//     error: (_, __) => null,
//   );
// });

// // Session provider
// final sessionProvider = Provider<Session?>((ref) {
//   final authState = ref.watch(authStateProvider);
//   return authState.when(
//     data: (auth) => auth.session,
//     loading: () => null,
//     error: (_, __) => null,
//   );
// });

// part of '../supabase_client.dart';

// enum SupabaseAPIType { public, private }

// class SupabaseResponse<T> {
//   SupabaseResponse.success(this.data) : error = null;
//   SupabaseResponse.failure(this.error) : data = null;
//   final T? data;
//   final PostgrestException? error;

//   bool get isSuccess => error == null;
// }

// final supabaseClientProvider = Provider<SupabaseApiClient>((ref) {
//   return SupabaseApiClient.instance;
// });

// class SupabaseApiClient {
//   SupabaseApiClient._internal();

//   static final SupabaseApiClient _instance = SupabaseApiClient._internal();
//   static SupabaseApiClient get instance => _instance;

//   // Use the global Supabase instance from supabase_flutter
//   static final SupabaseClient _supabase = Supabase.instance.client;
//   SupabaseClient get supabase => _supabase;

//   Future<SupabaseResponse<List<Map<String, dynamic>>>> get({
//     required String table,
//     String select = '*',
//     Map<String, dynamic>? filters,
//     String? orderBy,
//     bool ascending = true,
//     int? limit,
//     int? offset,
//   }) async {
//     try {
//       dynamic query = _supabase.from(table).select(select);

//       // Apply filters
//       if (filters != null) {
//         filters.forEach((key, value) {
//           if (value is List) {
//             query = query.inFilter(key, value);
//           } else if (value is String && value.contains('%')) {
//             query = query.ilike(key, value);
//           } else {
//             query = query.eq(key, value);
//           }
//         });
//       }

//       // Apply ordering
//       if (orderBy != null) {
//         query = query.order(orderBy, ascending: ascending);
//       }

//       // Apply pagination
//       if (limit != null) {
//         query = query.limit(limit);
//       }
//       if (offset != null) {
//         query = query.range(offset, offset + (limit ?? 1000) - 1);
//       }

//       final response = await query;
//       return SupabaseResponse.success(response as List<Map<String, dynamic>>);
//     } on PostgrestException catch (e) {
//       return _handleSupabaseException(e);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// GET Single - Query single record
//   Future<SupabaseResponse<Map<String, dynamic>?>> getSingle({
//     required String table,
//     String select = '*',
//     required Map<String, dynamic> filters,
//   }) async {
//     try {
//       dynamic query = _supabase.from(table).select(select);

//       // Apply filters
//       filters.forEach((key, value) {
//         query = query.eq(key, value);
//       });

//       final response = await query.single();
//       return SupabaseResponse.success(response as Map<String, dynamic>);
//     } on PostgrestException catch (e) {
//       return _handleSupabaseException(e);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// POST - Insert data into table
//   Future<SupabaseResponse<List<Map<String, dynamic>>>> post({
//     required String table,
//     required Map<String, dynamic> data,
//     bool upsert = false,
//     String? onConflict,
//     bool returnData = true,
//   }) async {
//     try {
//       dynamic query;

//       if (upsert) {
//         query = _supabase.from(table).upsert(data, onConflict: onConflict);
//       } else {
//         query = _supabase.from(table).insert(data);
//       }

//       if (returnData) {
//         final response = await query.select();
//         return SupabaseResponse.success(response as List<Map<String, dynamic>>);
//       } else {
//         await query;
//         return SupabaseResponse.success(<Map<String, dynamic>>[]);
//       }
//     } on PostgrestException catch (e) {
//       return _handleSupabaseException(e);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// POST - Insert multiple records
//   Future<SupabaseResponse<List<Map<String, dynamic>>>> postBatch({
//     required String table,
//     required List<Map<String, dynamic>> data,
//     bool upsert = false,
//     String? onConflict,
//     bool returnData = true,
//   }) async {
//     try {
//       dynamic query;

//       if (upsert) {
//         query = _supabase.from(table).upsert(data, onConflict: onConflict);
//       } else {
//         query = _supabase.from(table).insert(data);
//       }

//       if (returnData) {
//         final response = await query.select();
//         return SupabaseResponse.success(response as List<Map<String, dynamic>>);
//       } else {
//         await query;
//         return SupabaseResponse.success(<Map<String, dynamic>>[]);
//       }
//     } on PostgrestException catch (e) {
//       return _handleSupabaseException(e);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// PUT/PATCH - Update data
//   Future<SupabaseResponse<List<Map<String, dynamic>>>> update({
//     required String table,
//     required Map<String, dynamic> data,
//     required Map<String, dynamic> filters,
//     bool returnData = true,
//   }) async {
//     try {
//       dynamic query = _supabase.from(table).update(data);

//       // Apply filters
//       filters.forEach((key, value) {
//         if (value is List) {
//           query = query.inFilter(key, value);
//         } else {
//           query = query.eq(key, value);
//         }
//       });

//       if (returnData) {
//         final response = await query.select();
//         return SupabaseResponse.success(response as List<Map<String, dynamic>>);
//       } else {
//         await query;
//         return SupabaseResponse.success(<Map<String, dynamic>>[]);
//       }
//     } on PostgrestException catch (e) {
//       return _handleSupabaseException(e);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// DELETE
//   Future<SupabaseResponse<List<Map<String, dynamic>>>> delete({
//     required String table,
//     required Map<String, dynamic> filters,
//     bool returnData = false,
//   }) async {
//     try {
//       dynamic query = _supabase.from(table).delete();

//       // Apply filters
//       filters.forEach((key, value) {
//         if (value is List) {
//           query = query.inFilter(key, value);
//         } else {
//           query = query.eq(key, value);
//         }
//       });

//       if (returnData) {
//         final response = await query.select();
//         return SupabaseResponse.success(response as List<Map<String, dynamic>>);
//       } else {
//         await query;
//         return SupabaseResponse.success(<Map<String, dynamic>>[]);
//       }
//     } on PostgrestException catch (e) {
//       return _handleSupabaseException(e);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// File Upload to Supabase Storage
//   Future<SupabaseResponse<String>> uploadFile({
//     required String bucket,
//     required String path,
//     required File file,
//     bool upsert = false,
//   }) async {
//     try {
//       final bytes = await file.readAsBytes();
//       final fileExt = file.path.split('.').last.toLowerCase();
//       final fileName = path.endsWith('.$fileExt') ? path : '$path.$fileExt';

//       await _supabase.storage
//           .from(bucket)
//           .uploadBinary(
//             fileName,
//             bytes,
//             fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
//           );

//       // Get public URL
//       final publicUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);

//       return SupabaseResponse.success(publicUrl);
//     } on StorageException catch (e) {
//       return SupabaseResponse.failure(
//         PostgrestException(message: e.message, code: e.statusCode),
//       );
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// Upload multiple files
//   Future<SupabaseResponse<List<String>>> uploadFiles({
//     required String bucket,
//     required Map<String, File> files, // path -> file mapping
//     bool upsert = false,
//   }) async {
//     try {
//       final List<String> uploadedUrls = [];

//       for (final entry in files.entries) {
//         final path = entry.key;
//         final file = entry.value;

//         final response = await uploadFile(
//           bucket: bucket,
//           path: path,
//           file: file,
//           upsert: upsert,
//         );

//         if (response.isSuccess) {
//           uploadedUrls.add(response.data!);
//         } else {
//           return SupabaseResponse.failure(response.error!);
//         }
//       }

//       return SupabaseResponse.success(uploadedUrls);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// Download File from Supabase Storage
//   Future<SupabaseResponse<Uint8List>> downloadFile({
//     required String bucket,
//     required String path,
//   }) async {
//     try {
//       final response = await _supabase.storage.from(bucket).download(path);
//       return SupabaseResponse.success(response);
//     } on StorageException catch (e) {
//       return SupabaseResponse.failure(
//         PostgrestException(message: e.message, code: e.statusCode),
//       );
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// Delete file from storage
//   Future<SupabaseResponse<bool>> deleteFile({
//     required String bucket,
//     required String path,
//   }) async {
//     try {
//       await _supabase.storage.from(bucket).remove([path]);
//       return SupabaseResponse.success(true);
//     } on StorageException catch (e) {
//       return SupabaseResponse.failure(
//         PostgrestException(message: e.message, code: e.statusCode),
//       );
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// Get Public URL for file
//   String getPublicUrl({required String bucket, required String path}) {
//     return _supabase.storage.from(bucket).getPublicUrl(path);
//   }

//   /// Get Signed URL for private files
//   Future<SupabaseResponse<String>> getSignedUrl({
//     required String bucket,
//     required String path,
//     int expiresInSeconds = 3600,
//   }) async {
//     try {
//       final response = await _supabase.storage
//           .from(bucket)
//           .createSignedUrl(path, expiresInSeconds);
//       return SupabaseResponse.success(response);
//     } on StorageException catch (e) {
//       return SupabaseResponse.failure(
//         PostgrestException(message: e.message, code: e.statusCode),
//       );
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// Execute RPC (Remote Procedure Call)
//   Future<SupabaseResponse<dynamic>> rpc({
//     required String functionName,
//     Map<String, dynamic>? params,
//   }) async {
//     try {
//       final response = await _supabase.rpc(functionName, params: params);
//       return SupabaseResponse.success(response);
//     } on PostgrestException catch (e) {
//       return _handleSupabaseException(e);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// Real-time subscription
//   RealtimeChannel subscribe({
//     required String table,
//     String? schema = 'public',
//     String? filter,
//     void Function(Map<String, dynamic>)? onInsert,
//     void Function(Map<String, dynamic>)? onUpdate,
//     void Function(Map<String, dynamic>)? onDelete,
//   }) {
//     final channel = _supabase.channel(
//       '$schema:$table:${DateTime.now().millisecondsSinceEpoch}',
//     );

//     if (onInsert != null) {
//       channel.onPostgresChanges(
//         event: PostgresChangeEvent.insert,
//         schema: schema ?? 'public',
//         table: table,
//         filter: filter != null
//             ? PostgresChangeFilter(
//                 type: PostgresChangeFilterType.eq,
//                 column: filter.split('=')[0],
//                 value: filter.split('=')[1],
//               )
//             : null,
//         callback: (payload) => onInsert(payload.newRecord ?? {}),
//       );
//     }

//     if (onUpdate != null) {
//       channel.onPostgresChanges(
//         event: PostgresChangeEvent.update,
//         schema: schema ?? 'public',
//         table: table,
//         filter: filter != null
//             ? PostgresChangeFilter(
//                 type: PostgresChangeFilterType.eq,
//                 column: filter.split('=')[0],
//                 value: filter.split('=')[1],
//               )
//             : null,
//         callback: (payload) => onUpdate(payload.newRecord ?? {}),
//       );
//     }

//     if (onDelete != null) {
//       channel.onPostgresChanges(
//         event: PostgresChangeEvent.delete,
//         schema: schema ?? 'public',
//         table: table,
//         filter: filter != null
//             ? PostgresChangeFilter(
//                 type: PostgresChangeFilterType.eq,
//                 column: filter.split('=')[0],
//                 value: filter.split('=')[1],
//               )
//             : null,
//         callback: (payload) => onDelete(payload.oldRecord ?? {}),
//       );
//     }

//     channel.subscribe();
//     return channel;
//   }

//   User? get currentUser => _supabase.auth.currentUser;
//   Session? get currentSession => _supabase.auth.currentSession;
//   bool get isAuthenticated => _supabase.auth.currentUser != null;

//   Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;

//   /// Count records in table
//   Future<SupabaseResponse<int>> count({
//     required String table,
//     Map<String, dynamic>? filters,
//   }) async {
//     try {
//       dynamic query = _supabase.from(table).select('*');

//       // Apply filters
//       if (filters != null) {
//         filters.forEach((key, value) {
//           if (value is List) {
//             query = query.inFilter(key, value);
//           } else {
//             query = query.eq(key, value);
//           }
//         });
//       }

//       final response = await query;
//       return SupabaseResponse.success(response.count ?? 0);
//     } on PostgrestException catch (e) {
//       return _handleSupabaseException(e);
//     } catch (e) {
//       return _handleGenericException(e);
//     }
//   }

//   /// Private helper methods
//   SupabaseResponse<T> _handleSupabaseException<T>(PostgrestException e) {
//     debugPrint('PostgrestException → ${e.code}');
//     debugPrint('Error message → ${e.message}');

//     return SupabaseResponse.failure(e);
//   }

//   SupabaseResponse<T> _handleGenericException<T>(dynamic e) {
//     debugPrint('Generic Exception → ${e.toString()}');

//     return SupabaseResponse.failure(
//       PostgrestException(message: e.toString(), code: 'UNKNOWN_ERROR'),
//     );
//   }
// }

// // Extension for easier filtering
// extension SupabaseQueryExtension on PostgrestQueryBuilder {
//   dynamic applyFilters(Map<String, dynamic> filters) {
//     dynamic query = this;
//     filters.forEach((key, value) {
//       if (value is List) {
//         query = query.inFilter(key, value);
//       } else if (value is String && value.contains('%')) {
//         query = query.ilike(key, value);
//       } else {
//         query = query.eq(key, value);
//       }
//     });
//     return query;
//   }
// }
