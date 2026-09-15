// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String? email;
  final String role;
  final String? phoneNumber;
  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.image,
    this.email,
    this.role = "user",
    this.phoneNumber,
  });

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? image,
    String? email,
    String? role,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      image: image ?? this.image,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstname': firstName,
      'lastname': lastName,
      'image': image,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
    }..removeWhere((key, value) => value == null);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final meta = map['user_metadata'] as Map<String, dynamic>? ?? {};

    // Google sends `full_name` / `name` but no dedicated first_name/last_name.
    // Split the full name so we populate both fields correctly.
    String? splitFirst(String? full) {
      if (full == null || full.trim().isEmpty) return null;
      final parts = full.trim().split(' ');
      return parts.first;
    }

    String? splitLast(String? full) {
      if (full == null || full.trim().isEmpty) return null;
      final parts = full.trim().split(' ');
      return parts.length > 1 ? parts.sublist(1).join(' ') : null;
    }

    final fullName =
        meta['full_name'] as String? ??
        meta['name'] as String? ??
        map['full_name'] as String?;

    final resolvedFirstName =
        map['firstname'] as String? ??
        map['firstName'] as String? ??
        meta['firstname'] as String? ??
        map['first_name'] as String? ??
        meta['first_name'] as String? ??
        splitFirst(fullName);

    final resolvedLastName =
        map['lastname'] as String? ??
        meta['lastname'] as String? ??
        map['last_name'] as String? ??
        meta['last_name'] as String? ??
        splitLast(fullName);

    // Supabase sets `role` to "authenticated" in auth responses.
    // Map that back to the app-level default "user".
    final rawRole = map['role'] as String? ?? meta['role'] as String?;
    final resolvedRole = (rawRole == null || rawRole == 'authenticated')
        ? 'user'
        : rawRole;

    return UserModel(
      id: map['id'] as String?,
      firstName: resolvedFirstName,
      lastName: resolvedLastName,
      image:
          map['image'] as String? ??
          map['avatar_url'] as String? ??
          meta['image'] as String? ??
          meta['avatar_url'] as String? ??
          meta['picture'] as String?, // Google OAuth sends `picture`
      email: (map['email'] ?? meta['email']) as String?,
      role: resolvedRole,
      phoneNumber:
          map['phoneNumber'] as String? ??
          map['phone_number'] as String? ??
          meta['phoneNumber'] as String? ??
          meta['phone_number'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, image: $image, email: $email, role: $role, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.image == image &&
        other.email == email &&
        other.role == role &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        image.hashCode ^
        email.hashCode ^
        role.hashCode ^
        phoneNumber.hashCode;
  }
}
