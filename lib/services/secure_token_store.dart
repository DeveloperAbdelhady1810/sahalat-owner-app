// Copyright © 2025 Quadro Tech. All rights reserved.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The login token lives in the platform secure storage (Android Keystore-backed EncryptedSharedPreferences, iOS Keychain),
/// not in a plain Hive box / SharedPreferences file. `token` is a synchronous copy kept in memory so the HTTP client does not
/// have to await a plugin call on every request.
class SecureTokenStore {
  static const _key = 'auth_token';
  static const FlutterSecureStorage _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  static String? _cache;

  static String? get token => (_cache == null || _cache!.isEmpty) ? null : _cache;

  /// Call once at start-up. Moves a token that an older version kept in plain storage into the secure storage and wipes the
  /// old copy, but only after the secure copy was read back correctly (a device with a broken keystore keeps working as before).
  static Future<void> init({Future<String?> Function()? legacyRead, Future<void> Function()? legacyWipe}) async {
    try {
      _cache = await _s.read(key: _key);
    } catch (_) {
      _cache = null;
    }
    String? old;
    if (legacyRead != null) {
      try {
        old = await legacyRead();
      } catch (_) {}
    }
    if ((token == null) && old != null && old.isNotEmpty) {
      await save(old);
    }
    if (legacyWipe != null && old != null && old.isNotEmpty) {
      String? check;
      try {
        check = await _s.read(key: _key);
      } catch (_) {}
      if (check != null && check.isNotEmpty) {
        try {
          await legacyWipe();
        } catch (_) {}
      }
    }
  }

  /// For a background isolate (its memory copy is empty): read straight from the secure storage.
  static Future<String?> readFresh() async {
    try {
      final v = await _s.read(key: _key);
      return (v == null || v.isEmpty) ? null : v;
    } catch (_) {
      return token;
    }
  }

  static Future<void> save(String value) async {
    _cache = value;
    try {
      await _s.write(key: _key, value: value);
    } catch (_) {}
  }

  static Future<void> clear() async {
    _cache = null;
    try {
      await _s.delete(key: _key);
    } catch (_) {}
  }
}
