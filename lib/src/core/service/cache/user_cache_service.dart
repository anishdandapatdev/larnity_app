import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used to store user profile fields in SharedPreferences.
class _Keys {
  static const firstName = 'user_firstName';
  static const lastName = 'user_lastName';
  static const image = 'user_image';
  static const phoneNumber = 'user_phoneNumber';
}

/// A simple SharedPreferences-backed cache for user profile data.
/// Call [saveUser] after a successful login; call [clearUser] on sign-out.
class UserCacheService {
  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveUser({
    String? firstName,
    String? lastName,
    String? image,
    String? phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (firstName != null) await prefs.setString(_Keys.firstName, firstName);
    if (lastName != null) await prefs.setString(_Keys.lastName, lastName);
    if (image != null) await prefs.setString(_Keys.image, image);
    if (phoneNumber != null) {
      await prefs.setString(_Keys.phoneNumber, phoneNumber);
    }
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_Keys.firstName);
  }

  Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_Keys.lastName);
  }

  Future<String?> getImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_Keys.image);
  }

  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_Keys.phoneNumber);
  }

  /// Returns all cached profile fields as a map.
  Future<Map<String, String?>> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString(_Keys.firstName),
      'lastName': prefs.getString(_Keys.lastName),
      'image': prefs.getString(_Keys.image),
      'phoneNumber': prefs.getString(_Keys.phoneNumber),
    };
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_Keys.firstName);
    await prefs.remove(_Keys.lastName);
    await prefs.remove(_Keys.image);
    await prefs.remove(_Keys.phoneNumber);
  }
}

/// Riverpod provider — use [ref.read(userCacheServiceProvider)] anywhere.
final userCacheServiceProvider = Provider<UserCacheService>(
  (_) => UserCacheService(),
);
