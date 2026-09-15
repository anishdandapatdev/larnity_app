import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String? id;
  final String name;
  final String description;
  final num price;
  final String whatsappNumber;
  final String imageUrl;
  final String groupId;
  final String type; // 'product' or 'service'
  final num? discountPrice;
  final int rating;
  final String? affiliateLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.whatsappNumber,
    required this.imageUrl,
    required this.groupId,
    required this.type,
    this.discountPrice,
    this.rating = 0,
    this.affiliateLink,
    this.createdAt,
    this.updatedAt,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    num? price,
    String? whatsappNumber,
    String? imageUrl,
    String? groupId,
    String? type,
    num? discountPrice,
    int? rating,
    String? affiliateLink,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      discountPrice: discountPrice ?? this.discountPrice,
      rating: rating ?? this.rating,
      affiliateLink: affiliateLink ?? this.affiliateLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'whatsappNumber': whatsappNumber,
      'imageUrl': imageUrl,
      'groupId': groupId,
      'type': type,
      if (discountPrice != null) 'discountPrice': discountPrice,
      'rating': rating,
      if (affiliateLink != null) 'affiliateLink': affiliateLink,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as num,
      whatsappNumber: map['whatsappNumber'] as String,
      imageUrl: map['imageUrl'] as String,
      groupId: map['groupId'] as String,
      type: map['type'] as String,
      discountPrice: map['discountPrice'] != null ? map['discountPrice'] as num : null,
      rating: map['rating'] != null ? (map['rating'] as num).toInt() : 0,
      affiliateLink: map['affiliateLink'] != null ? map['affiliateLink'] as String : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      description,
      price,
      whatsappNumber,
      imageUrl,
      groupId,
      type,
      discountPrice,
      rating,
      affiliateLink,
      createdAt,
      updatedAt,
    ];
  }
}
