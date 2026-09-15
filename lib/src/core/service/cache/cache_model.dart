// import 'package:hive/hive.dart';
// import 'package:equatable/equatable.dart';

// class CacheEntry extends Equatable {
//   final String key;
//   final dynamic data;

//   const CacheEntry({required this.key, required this.data});

//   @override
//   List<Object> get props => [key, data];
// }

// class CacheEntryAdapter extends TypeAdapter<CacheEntry> {
//   @override
//   final int typeId = 0;

//   @override
//   CacheEntry read(BinaryReader reader) {
//     final key = reader.readString();
//     final data = reader.read();
//     return CacheEntry(key: key, data: data);
//   }

//   @override
//   void write(BinaryWriter writer, CacheEntry obj) {
//     writer.writeString(obj.key);
//     writer.write(obj.data);
//   }
// }
