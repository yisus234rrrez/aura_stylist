import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef JsonParser<T> = T Function(dynamic json);

class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    this.data,
    this.message,
    this.rawData,
  });

  final int statusCode;
  final T? data;
  final String? message;
  final dynamic rawData;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isUnauthorized => statusCode == 401;
  bool get hasData => data != null;
}

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiNetworkException extends ApiException {
  const ApiNetworkException([super.message = 'No hay conexión con el servidor.']);
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([super.message = 'La solicitud tardó demasiado.']);
}

class ApiService {
  ApiService({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
    this.onUnauthorized,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final VoidCallback? onUnauthorized;
  final http.Client _client;

  String? _token;
  int? _empresaId;

  String? get token => _token;
  int? get empresaId => _empresaId;

  void setToken(String? token) => _token = token;
  void setEmpresaId(int? empresaId) => _empresaId = empresaId;

  void close() => _client.close();

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    JsonParser<T>? parser,
  }) =>
      _request<T>('GET', path, query: query, parser: parser);

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    JsonParser<T>? parser,
  }) =>
      _request<T>('POST', path, body: body, parser: parser);

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    JsonParser<T>? parser,
  }) =>
      _request<T>('PUT', path, body: body, parser: parser);

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? body,
    JsonParser<T>? parser,
  }) =>
      _request<T>('PATCH', path, body: body, parser: parser);

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? body,
    JsonParser<T>? parser,
  }) =>
      _request<T>('DELETE', path, body: body, parser: parser);

  Future<ApiResponse<T>> _request<T>(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    JsonParser<T>? parser,
  }) async {
    final Uri uri = _buildUri(path, query);
    final http.Request request = http.Request(method, uri)
      ..headers.addAll(<String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null && _token!.isNotEmpty)
          'Authorization': 'Bearer $_token',
        if (_empresaId != null) 'X-Empresa-Id': '$_empresaId',
      });

    if (body != null) {
      request.body = body is String ? body : jsonEncode(body);
    }

    try {
      final http.Response response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);

      dynamic decoded;
      if (response.bodyBytes.isNotEmpty) {
        final String text = utf8.decode(response.bodyBytes, allowMalformed: true);
        try {
          decoded = jsonDecode(text);
        } on FormatException {
          decoded = text;
        }
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 401 &&
            !path.toLowerCase().contains('/sesion')) {
          onUnauthorized?.call();
        }
        return ApiResponse<T>(
          statusCode: response.statusCode,
          message: _extractMessage(decoded, response.statusCode, response.reasonPhrase),
          rawData: decoded,
        );
      }

      if (decoded == null) {
        return ApiResponse<T>(
          statusCode: response.statusCode,
          rawData: decoded,
        );
      }

      final dynamic payload = _unwrap(decoded);
      return ApiResponse<T>(
        statusCode: response.statusCode,
        data: parser == null ? payload as T? : parser(payload),
        rawData: decoded,
      );
    } on TimeoutException {
      throw const ApiTimeoutException();
    } on http.ClientException {
      throw const ApiNetworkException();
    }
  }

  dynamic _unwrap(dynamic decoded) {
    if (decoded is Map && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }

  String _extractMessage(dynamic data, int status, String? reason) {
    if (data is Map) {
      final dynamic message =
          data['message'] ?? data['error'] ?? data['detail'] ?? data['title'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return reason?.isNotEmpty == true
        ? reason!
        : 'Error del servidor ($status)';
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final Uri base = Uri.parse(baseUrl);
    final String basePath = base.path.replaceAll(RegExp(r'/+$'), '');
    final String cleanPath = path.replaceAll(RegExp(r'^/+'), '');
    final Map<String, String> params = <String, String>{};
    if (query != null) {
      for (final entry in query.entries) {
        if (entry.value != null) params[entry.key] = entry.value.toString();
      }
    }
    return base.replace(
      path: '$basePath/$cleanPath',
      queryParameters: params.isEmpty ? null : params,
    );
  }
}

typedef VoidCallback = void Function();
