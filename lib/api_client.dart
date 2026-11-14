import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final int? kod;
  final String mesaj;
  ApiException(this.mesaj, {this.kod});
}

class ApiClient {
  /// 401 gələndə (token yoxdur və ya vaxtı bitib) çağırılır:
  /// tətbiq giriş ekranına qayıdır.
  static VoidCallback? sessiyaBitdi;

  static const _limit = Duration(seconds: 90);

  static Future<Map<String, String>> _basliqlar() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> _icra(
    Future<http.Response> Function(Map<String, String> basliqlar) sorgu,
  ) async {
    final http.Response res;
    try {
      res = await sorgu(await _basliqlar()).timeout(_limit);
    } catch (_) {
      throw ApiException('Serverlə əlaqə qurulmadı');
    }

    dynamic govde;
    try {
      final metn = utf8.decode(res.bodyBytes);
      govde = metn.isEmpty ? null : jsonDecode(metn);
    } catch (_) {
      govde = null;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return govde;

    if (res.statusCode == 401) {
      sessiyaBitdi?.call();
      throw ApiException('Sessiya bitib, yenidən daxil ol', kod: 401);
    }

    var mesaj = 'Server xətası (${res.statusCode})';
    if (govde is Map && govde['detail'] is String) {
      mesaj = govde['detail'] as String;
    } else if (res.statusCode == 422) {
      mesaj = 'Məlumatlar düzgün deyil';
    }
    throw ApiException(mesaj, kod: res.statusCode);
  }

  static Future<dynamic> get(String yol) =>
      _icra((h) => http.get(Uri.parse('$baseUrl$yol'), headers: h));

  static Future<dynamic> put(String yol, Object govde) => _icra(
        (h) => http.put(Uri.parse('$baseUrl$yol'),
            headers: h, body: jsonEncode(govde)),
      );

  static Future<dynamic> post(String yol, [Object? govde]) => _icra(
        (h) => http.post(Uri.parse('$baseUrl$yol'),
            headers: h, body: govde == null ? null : jsonEncode(govde)),
      );
}