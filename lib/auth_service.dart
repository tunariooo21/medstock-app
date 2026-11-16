import 'l10n.dart' hide ayAdi;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class Session {
  final String ad;
  final String rol;
  final List<String> regionlar;
  final String login;
  final String? email;
  final String? telefon;
  final String? whatsapp;
  final String? photo;

  Session({
    required this.ad,
    required this.rol,
    this.regionlar = const [],
    this.login = '',
    this.email,
    this.telefon,
    this.whatsapp,
    this.photo,
  });

  factory Session.fromJson(Map<String, dynamic> j) => Session(
    ad: j['ad'] as String,
    rol: j['rol'] as String,
    regionlar: List<String>.from(j['regionlar'] ?? []),
    login: (j['login'] ?? '') as String,
    email: j['email'] as String?,
    telefon: j['telefon'] as String?,
    whatsapp: j['whatsapp'] as String?,
    photo: j['photo'] as String?,
  );
}

class AuthException implements Exception {
  final String mesaj;
  AuthException(this.mesaj);
}

class KodNeticesi {
  final bool demo;
  final String? kod;
  final String mesaj;
  KodNeticesi({required this.demo, this.kod, required this.mesaj});
}

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Map<String, String> _basliqlar(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  static String _xetaMetni(http.Response res, String ehtiyat) {
    try {
      final d = jsonDecode(utf8.decode(res.bodyBytes));
      if (d is Map && d['detail'] is String) return t(d['detail'] as String);
    } catch (_) {}
    return ehtiyat;
  }

  static Future<Session> _sessiyaAl(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    try {
      final me = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: _basliqlar(token),
      );
      if (me.statusCode == 200) {
        return Session.fromJson(jsonDecode(utf8.decode(me.bodyBytes)));
      }
      if (me.statusCode == 401) {
        await _storage.delete(key: _tokenKey);
        throw AuthException(t('Sessiya bitib, yenidən daxil ol'));
      }
      throw AuthException('${t('Server xətası')} (${me.statusCode})');
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException(t('Serverlə əlaqə qurulmadı'));
    }
  }

  static Future<Session> login(String login, String parol) async {
    final http.Response res;
    try {
      res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': login, 'parol': parol}),
      );
    } catch (_) {
      throw AuthException(t('Serverlə əlaqə qurulmadı'));
    }
    if (res.statusCode == 401) {
      throw AuthException(t('Login və ya şifrə yanlışdır'));
    }
    if (res.statusCode != 200) {
      throw AuthException(
        _xetaMetni(res, '${t('Server xətası')} (${res.statusCode})'),
      );
    }
    final token = jsonDecode(utf8.decode(res.bodyBytes))['token'] as String;
    return _sessiyaAl(token);
  }

  static Future<Session> register({
    required String ad,
    required String login,
    required String email,
    required String parol,
  }) async {
    final http.Response res;
    try {
      res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ad': ad,
          'login': login,
          'email': email,
          'parol': parol,
        }),
      );
    } catch (_) {
      throw AuthException(t('Serverlə əlaqə qurulmadı'));
    }
    if (res.statusCode == 409) {
      throw AuthException(_xetaMetni(res, t('Bu hesab artıq mövcuddur')));
    }
    if (res.statusCode == 422) {
      throw AuthException(
        t('Məlumatları yoxla: e-poçt və şifrə düzgün olmalıdır'),
      );
    }
    if (res.statusCode != 200) {
      throw AuthException(
        _xetaMetni(res, '${t('Server xətası')} (${res.statusCode})'),
      );
    }
    final token = jsonDecode(utf8.decode(res.bodyBytes))['token'] as String;
    return _sessiyaAl(token);
  }

  static Future<KodNeticesi> forgotPassword(String email) async {
    final http.Response res;
    try {
      res = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
    } catch (_) {
      throw AuthException(t('Serverlə əlaqə qurulmadı'));
    }
    if (res.statusCode == 429) {
      throw AuthException(_xetaMetni(res, t('Bir az sonra yenidən cəhd edin')));
    }
    if (res.statusCode == 502) {
      throw AuthException(_xetaMetni(res, t('E-poçt göndərilmədi')));
    }
    if (res.statusCode != 200) {
      throw AuthException(
        _xetaMetni(res, '${t('Server xətası')} (${res.statusCode})'),
      );
    }
    final d = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return KodNeticesi(
      demo: d['demo'] == true,
      kod: d['kod'] as String?,
      mesaj: (d['mesaj'] ?? t('Kod göndərildi')) as String,
    );
  }

  static Future<String> verifyCode(String email, String kod) async {
    final http.Response res;
    try {
      res = await http.post(
        Uri.parse('$baseUrl/auth/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'kod': kod}),
      );
    } catch (_) {
      throw AuthException(t('Serverlə əlaqə qurulmadı'));
    }
    if (res.statusCode == 429) {
      throw AuthException(
        _xetaMetni(res, t('Çox cəhd edildi. Yeni kod istəyin')),
      );
    }
    if (res.statusCode != 200) {
      throw AuthException(
        _xetaMetni(res, t('Kod yanlışdır və ya vaxtı bitib')),
      );
    }
    return jsonDecode(utf8.decode(res.bodyBytes))['reset_token'] as String;
  }

  static Future<void> resetPassword(String resetToken, String yeni) async {
    final http.Response res;
    try {
      res = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reset_token': resetToken, 'yeni_parol': yeni}),
      );
    } catch (_) {
      throw AuthException(t('Serverlə əlaqə qurulmadı'));
    }
    if (res.statusCode == 422) {
      throw AuthException(t('Yeni şifrə ən azı 8 simvol olmalıdır'));
    }
    if (res.statusCode != 200) {
      throw AuthException(
        _xetaMetni(res, t('Şifrə yenilənmədi. Yenidən kod istəyin')),
      );
    }
  }

  /// Saxlanmış token etibarlıdırsa sessiyanı qaytarır, yoxsa null.
  static Future<Session?> restore() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: _basliqlar(token),
      );
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

  static Future<Session> updateProfile({
    required String ad,
    String? telefon,
    String? whatsapp,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw AuthException(t('Sessiya bitib, yenidən daxil ol'));
    }
    final http.Response res;
    try {
      res = await http.put(
        Uri.parse('$baseUrl/me/profile'),
        headers: _basliqlar(token),
        body: jsonEncode({'ad': ad, 'telefon': telefon, 'whatsapp': whatsapp}),
      );
    } catch (_) {
      throw AuthException(t('Serverlə əlaqə qurulmadı'));
    }
    if (res.statusCode == 200) {
      return Session.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    if (res.statusCode == 401) {
      throw AuthException(t('Sessiya bitib, yenidən daxil ol'));
    }
    throw AuthException(_xetaMetni(res, t('Profil yadda saxlanmadı')));
  }

  static Future<void> changePassword(String kohne, String yeni) async {
    final token = await getToken();
    if (token == null) {
      throw AuthException(t('Sessiya bitib, yenidən daxil ol'));
    }
    final http.Response res;
    try {
      res = await http.post(
        Uri.parse('$baseUrl/me/password'),
        headers: _basliqlar(token),
        body: jsonEncode({'kohne_parol': kohne, 'yeni_parol': yeni}),
      );
    } catch (_) {
      throw AuthException(t('Serverlə əlaqə qurulmadı'));
    }
    if (res.statusCode == 200) return;
    if (res.statusCode == 400) {
      throw AuthException(_xetaMetni(res, t('Məlumatlar düzgün deyil')));
    }
    if (res.statusCode == 401) {
      throw AuthException(t('Sessiya bitib, yenidən daxil ol'));
    }
    if (res.statusCode == 422) {
      throw AuthException(t('Yeni şifrə ən azı 8 simvol olmalıdır'));
    }
    throw AuthException('${t('Server xətası')} (${res.statusCode})');
  }

  static Future<void> logout() => _storage.delete(key: _tokenKey);
}
