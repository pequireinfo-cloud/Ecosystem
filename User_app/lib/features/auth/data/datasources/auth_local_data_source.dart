import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(AuthModel userToCache);
  Future<AuthModel?> getLastUser();
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_USER = 'CACHED_USER';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(AuthModel userToCache) {
    return sharedPreferences.setString(
      CACHED_USER,
      json.encode(userToCache.toJson()),
    );
  }

  @override
  Future<AuthModel?> getLastUser() {
    final jsonString = sharedPreferences.getString(CACHED_USER);
    if (jsonString != null) {
      return Future.value(AuthModel.fromJson(json.decode(jsonString)));
    } else {
      return Future.value(null);
    }
  }

  @override
  Future<void> cacheToken(String token) {
    return sharedPreferences.setString('JWT_TOKEN', token);
  }

  @override
  Future<String?> getToken() {
    return Future.value(sharedPreferences.getString('JWT_TOKEN'));
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(CACHED_USER);
    await sharedPreferences.remove('JWT_TOKEN');
  }
}
