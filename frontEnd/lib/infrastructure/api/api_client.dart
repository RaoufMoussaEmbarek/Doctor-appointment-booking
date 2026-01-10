import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8081';

  String? _jwt;

  // ---------------- TOKEN ----------------

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _jwt = prefs.getString('jwt');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
    _jwt = token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    _jwt = null;
  }

  bool get isAuthenticated => _jwt != null;

  // ---------------- AUTH ----------------

  Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      final token = jsonDecode(res.body)['accessToken'];
      await saveToken(token);
    } else if (res.statusCode == 401) {
      throw Exception('INVALID_CREDENTIALS');
    } else if (res.statusCode == 403) {
      throw Exception('USER_DISABLED');
    } else {
      throw Exception('SERVER_ERROR');
    }
  }

  // ---------------- REQUESTS ----------------

  Future<http.Response> get(String path) async {
    return _authorized(
      () => http.get(
        Uri.parse('$baseUrl$path'),
        headers: _authHeaders(),
      ),
    );
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _authorized(
      () => http.post(
        Uri.parse('$baseUrl$path'),
        headers: _authHeaders(),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _authorized(
      () => http.put(
        Uri.parse('$baseUrl$path'),
        headers: _authHeaders(),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  // ---------------- INTERNAL ----------------

  Map<String, String> _authHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_jwt != null) {
      headers['Authorization'] = 'Bearer $_jwt';
    }
    return headers;
  }

  Future<http.Response> _authorized(
    Future<http.Response> Function() request,
  ) async {
    if (_jwt == null) {
      throw Exception('NOT_AUTHENTICATED');
    }

    final res = await request();

    if (res.statusCode == 401) {
      await clearToken();
      throw Exception('SESSION_EXPIRED');
    }

    return res;
  }
}
