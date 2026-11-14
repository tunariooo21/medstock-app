import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class Session {
  final String ad;
  final String rol;
  final List<String> regionlar;
  Session({required this.ad, required this.rol, this.regionlar = const []});

  factory Session.fromJson(Map<String, dynamic> j) => Session(
        ad: j['ad'],
        rol: j['rol'],
        regionlar: List<String>.from(j['regionlar'] ?? []),
      );
}

class AuthException implements Exception {
  final String mesaj;
  AuthException(this.mesaj);
}

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Map<String, String> _basliqlar(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  static Future<Session> login(String login, String parol) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': login, 'parol': parol}),
      );
      if (res.statusCode == 401) {
        throw AuthException('Login və ya şifrə yanlışdır');
      }
      if (res.statusCode != 200) {
        throw AuthException('Server xətası (${res.statusCode})');
      }
      final token = jsonDecode(utf8.decode(res.bodyBytes))['token'] as String;
      await _storage.write(key: _tokenKey, value: token);

      final me = await http.get(Uri.parse('$baseUrl/me'),
          headers: _basliqlar(token));
      if (me.statusCode != 200) {
        throw AuthException('Server xətası (${me.statusCode})');
      }
      return Session.fromJson(jsonDecode(utf8.decode(me.bodyBytes)));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Serverlə əlaqə qurulmadı');
    }
  }

  /// Saxlanmış token etibarlıdırsa sessiyanı qaytarır, yoxsa null.
  static Future<Session?> restore() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final res = await http.get(Uri.parse('$baseUrl/me'),
          headers: _basliqlar(token));
      if (res.statusCode == 200) {
        return Session.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
      }
      if (res.statusCode == 401) {
        await _storage.delete(key: _tokenKey);
      }
    } catch (_) {
      // Şəbəkə xətası: token silinmir.
    }
    return null;
  }

  static Future<void> changePassword(String kohne, String yeni) async {
    final token = await getToken();
    if (token == null) throw AuthException('Sessiya bitib, yenidən daxil ol');
    final http.Response res;
    try {
      res = await http.post(
        Uri.parse('$baseUrl/me/password'),
        headers: _basliqlar(token),
        body: jsonEncode({'kohne_parol': kohne, 'yeni_parol': yeni}),
      );
    } catch (_) {
      throw AuthException('Serverlə əlaqə qurulmadı');
    }
    if (res.statusCode == 200) return;
    if (res.statusCode == 400) {
      final d = jsonDecode(utf8.decode(res.bodyBytes))['detail'];
      throw AuthException(d is String ? d : 'Məlumatlar düzgün deyil');
    }
    if (res.statusCode == 401) {
      throw AuthException('Sessiya bitib, yenidən daxil ol');
    }
    if (res.statusCode == 422) {
      throw AuthException('Yeni şifrə ən azı 8 simvol olmalıdır');
    }
    throw AuthException('Server xətası (${res.statusCode})');
  }

  static Future<void> logout() => _storage.delete(key: _tokenKey);
}