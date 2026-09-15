import 'package:equatable/equatable.dart';

class ProductServiceModel extends Equatable {
  final String? id;
  final String groupId;
  final String? type; // 'PRODUCT' or 'SERVICE'
  final String? title;
  final String? description;
  final double? price;
  final String? currency;
  final String? image;
  final List<String>? gallery;
  final String? category;
  final bool? isAvailable;
  final String? contactInfo;
  final String? link;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductServiceModel({
    this.id,
    required this.groupId,
    this.type,
    this.title,
    this.description,
    this.price,
    this.currency,
    this.image,
    this.gallery,
    this.category,
    this.isAvailable,
    this.contactInfo,
    this.link,
    this.createdAt,
    this.updatedAt,
  });

  ProductServiceModel copyWith({
    String? id,
    String? groupId,
    String? type,
    String? title,
    String? description,
    double? price,
    String? currency,
    String? image,
    List<String>? gallery,
    String? category,
    bool? isAvailable,
    String? contactInfo,
    String? link,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductServiceModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      image: image ?? this.image,
      gallery: gallery ?? this.gallery,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      contactInfo: contactInfo ?? this.contactInfo,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'groupId': groupId,
      'type': type,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'image': image,
      'gallery': gallery,
      'category': category,
      'isAvailable': isAvailable,
      'contactInfo': contactInfo,
      'link': link,
    }..removeWhere((key, value) => value == null);
  }

  factory ProductServiceModel.fromMap(Map<String, dynamic> map) {
    return ProductServiceModel(
      id: map['id'] as String?,
      groupId: map['groupId'] as String,
      type: map['type'] as String?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      currency: map['currency'] as String?,
      image: map['image'] as String?,
      gallery: map['gallery'] != null ? List<String>.from(map['gallery'] as List) : null,
      category: map['category'] as String?,
      isAvailable: map['isAvailable'] as bool? ?? true,
      contactInfo: map['contactInfo'] as String?,
      link: map['link'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  bool get isProduct => type == 'PRODUCT';
  bool get isService => type == 'SERVICE';

  @override
  List<Object?> get props => [
        id, groupId, type, title, description, price, currency,
        image, category, isAvailable, createdAt,
      ];

  @override
  bool get stringify => true;
}
