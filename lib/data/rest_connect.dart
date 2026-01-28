import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Seus imports da Lib
import 'package:innovare_core/data/auth_manager.dart';
import 'package:innovare_core/data/errors/rest_error.dart';
import 'package:innovare_core/data/errors/unknown_rest_error.dart';
import 'package:innovare_core/data/resource_dto.dart';
import 'package:innovare_core/data/rest_context.dart';
import 'package:innovare_core/data/rest_options.dart';
import 'package:innovare_core/data/upload_resource_dto.dart';
import 'package:innovare_core/extensions/generic_extensions.dart';

extension GetResponseExtensions on Response {
  bool get isBadRequest => status.code == HttpStatus.badRequest;

  bool get isUnauthorized => status.code == HttpStatus.unauthorized;

  bool get isForbidden => status.code == HttpStatus.forbidden;

  bool get isInternalServerError =>
      status.code == HttpStatus.internalServerError;

  bool get isCreated => status.code == HttpStatus.created;

  bool get isNotFound => status.code == HttpStatus.notFound;

  bool get isNoContent => status.code == HttpStatus.noContent;
}

class ResponseData {
  final bool successful;
  final String? errorMessage;
  final String? detailedErrorMessage;
  final String code;
  final dynamic data;

  ResponseData({
    required this.successful,
    this.errorMessage,
    this.detailedErrorMessage,
    required this.code,
    this.data
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
        successful: json['successful'] ?? false,
        errorMessage: json['errorMessage'],
        detailedErrorMessage: json['detailedErrorMessage'],
        code: json['code'] ?? '',
        data: json['data']
    );
  }

  String get message =>
      detailedErrorMessage ?? errorMessage ?? 'Erro desconhecido';
}

abstract class RestConnect<T extends RestContext> extends GetConnect {
  final T context;
  final AuthManager? _authManager;
  final _logger = Logger();

  // Header interno para evitar que rotas públicas caiam no loop de refresh
  static const String _skipAuthHeader = 'X-No-Refresh-Retry';

  bool _isRefreshing = false;

  RestOptions get defaultOptions =>
      RestOptions(
        timeout: const Duration(seconds: 30),
      );

  RestConnect(this.context, [this._authManager]) {
    httpClient.baseUrl = context.uri();

    final restOptions = context.options().orElse(defaultOptions);
    httpClient.timeout =
        restOptions.timeout.orElse(const Duration(seconds: 30));

    httpClient.addRequestModifier<dynamic>((request) async {
      if (kDebugMode) _logger.i('--> ${request.method} ${request.url}');
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      if (kDebugMode) {
        final status = response.statusText ?? response.statusCode.toString();
        if (response.isOk) {
          _logger.i('<-- ${response.statusCode} ${request.url}');
        } else {
          _logger.e('<-- ${response.statusCode} ${request.url} | $status');
        }
      }
      return response;
    });

    // 3. Autenticação Automática
    httpClient.addAuthenticator<dynamic>((Request request) async {
      // SE O HEADER DE BYPASS EXISTIR, RETORNA O REQUEST ORIGINAL (NÃO FAZ REFRESH)
      if (request.headers.containsKey(_skipAuthHeader)) {
        _logger.w(
            '[AUTH] 401 em rota pública ou login/refresh. Ignorando retry.');
        return request;
      }

      _logger.w('[AUTH] 401 detectado. Iniciando tentativa de refresh...');

      if (_authManager == null) return request;
      if (_isRefreshing) return request;

      _isRefreshing = true;

      try {
        final success = await _authManager.refreshToken();

        if (success) {
          _logger.i('[AUTH] Token renovado com sucesso.');
          final newToken = _authManager.getAccessToken();

          request.headers['Authorization'] = 'Bearer $newToken';
          return request;
        } else {
          _logger.e('[AUTH] Falha na renovação. Logout forçado.');
          _authManager.logout();
          return request;
        }
      } catch (e) {
        _logger.e('[AUTH] Erro crítico durante refresh: $e');
        return request;
      } finally {
        _isRefreshing = false;
      }
    });

    httpClient.maxAuthRetries = 1;
  }

  // --- Métodos HTTP ---

  Future<ResponseData> doPOST(String uri, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? contentType,
    bool requiresAuth = true,
  }) async {
    final response = await post(
        uri,
        body,
        contentType: contentType,
        headers: _completeHeaders(headers, requiresAuth),
        query: params
    );
    return _handleResponse(response);
  }

  Future<ResponseData> doPUT(String uri, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? contentType,
    bool requiresAuth = true,
  }) async {
    final response = await put(
        uri,
        body,
        contentType: contentType,
        headers: _completeHeaders(headers, requiresAuth),
        query: params
    );
    return _handleResponse(response);
  }

  Future<ResponseData> doPATCH(String uri, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? contentType,
    bool requiresAuth = true,
  }) async {
    final response = await patch(
        uri,
        body,
        contentType: contentType,
        headers: _completeHeaders(headers, requiresAuth),
        query: params
    );
    return _handleResponse(response);
  }

  Future<ResponseData> doGET(String uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? contentType,
    bool requiresAuth = true,
  }) async {
    final response = await get(
        uri,
        contentType: contentType,
        headers: _completeHeaders(headers, requiresAuth),
        query: params
    );
    return _handleResponse(response);
  }

  Future<ResponseData> doPOSTResource(String uri, UploadResourceDTO resource, {
    String fieldName = 'file',
    Map<String, dynamic>? params,
    Map<String, dynamic>? bodyFields,
  }) async {
    final Map<String, dynamic> data = {
      fieldName: MultipartFile(resource.bytes, filename: resource.name),
    };

    if (bodyFields != null) {
      data.addAll(bodyFields);
    }

    final formData = FormData(data);

    return await doPOST(uri, body: formData, params: params);
  }

  Future<ResponseData> doPOSTResources(String uri,
      List<UploadResourceDTO> resources, {
        String fieldName = 'files',
        Map<String, dynamic>? params,
        Map<String, String>? bodyFields,
      }) async {
    final List<MultipartFile> multipartFiles = resources.map((res) {
      return MultipartFile(res.bytes, filename: res.name);
    }).toList();

    final Map<String, dynamic> data = {
      fieldName: multipartFiles,
    };
    if (bodyFields != null) {
      data.addAll(bodyFields);
    }
    final formData = FormData(data);

    return await doPOST(uri, body: formData, params: params);
  }

  Future<ResourceDTO> doGETResource(String uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? contentType,
    bool requiresAuth = true,
  }) async {
    final baseUrl = httpClient.baseUrl ?? '';
    final finalUri = Uri.parse(baseUrl + uri).replace(queryParameters: params);

    final requestHeaders = _completeHeaders(headers, requiresAuth) ?? {};
    final client = http.Client();
    var response = await client.get(finalUri, headers: requestHeaders);

    if (response.statusCode == HttpStatus.unauthorized &&
        _authManager != null) {
      // Se não requer autenticação, não tenta refresh manual também
      if (requiresAuth) {
        _logger.w('[Download] 401 no download. Tentando refresh manual...');
        final success = await _authManager.refreshToken();
        if (success) {
          final newToken = _authManager.getAccessToken();
          requestHeaders['Authorization'] = 'Bearer $newToken';
          response = await client.get(finalUri, headers: requestHeaders);
        }
      }
    }

    if (response.statusCode == HttpStatus.ok) {
      final contentDisposition = response.headers["content-disposition"];
      final fileName = _extractFileName(contentDisposition);
      return ResourceDTO(fileName, response.bodyBytes);
    }

    throw RestError(
        Response(
            statusCode: response.statusCode, statusText: response.reasonPhrase),
        'Falha no download: ${response.statusCode}'
    );
  }

  String _extractFileName(String? contentDisposition) {
    if (contentDisposition != null) {
      RegExp regex = RegExp(r'filename="?([^"]+)"?');
      Match? match = regex.firstMatch(contentDisposition);
      if (match != null) return match.group(1) ?? "arquivo.bin";
    }
    return "arquivo_desconhecido";
  }

  Map<String, String>? _completeHeaders(Map<String, String>? currentHeaders,
      bool requiresAuth) {
    final headers = currentHeaders ?? {};

    if (requiresAuth) {
      if (_authManager == null) throw Exception('AuthManager não configurado.');

      final token = _authManager.getAccessToken();
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } else {
      // INJEÇÃO DA FLAG DE BYPASS
      // Se não requer auth, também não deve tentar refresh se der 401 (ex: login falhou)
      headers[_skipAuthHeader] = 'true';
    }

    return headers;
  }

  ResponseData _handleResponse(Response response) {
    // 1. Sem conexão ou Timeout
    if (response.status.connectionError) {
      throw RestError(response, 'Sem conexão com a internet ou servidor inacessível.');
    }

    // 2. Erros Críticos (500)
    if (response.isInternalServerError) {
      _logger.e('Erro 500: ${response.bodyString}');
      throw UnknownRestError(response);
    }

    // 3. Tenta extrair mensagem de erro do body (serve para 400, 401, 404, etc)
    String? serverMessage;
    try {
      if (response.body is Map<String, dynamic>) {
        final errorData = ResponseData.fromJson(response.body);
        // Só usamos se tiver uma mensagem válida diferente do default 'Erro desconhecido'
        if (errorData.message.isNotEmpty && errorData.message != 'Erro desconhecido') {
          serverMessage = errorData.message;
        }
      }
    } catch (_) {
      // Falha silenciosa no parse, vamos confiar nos status codes abaixo
    }

    // 4. Acesso Negado (401)
    if (response.isUnauthorized) {
      // Prioridade: Mensagem do servidor (ex: "Senha inválida") -> Mensagem genérica
      throw RestError(
          response,
          serverMessage ?? 'Sessão expirada ou credenciais inválidas.'
      );
    }

    // 5. Proibido (403)
    if (response.isForbidden) {
      throw RestError(
          response,
          serverMessage ?? 'Você não tem permissão para realizar esta ação.'
      );
    }

    // 6. Sucesso (2xx)
    if (response.isOk || response.isCreated) {
      if (response.body == null) {
        return ResponseData(successful: true, code: 'OK', data: null);
      }
      if (response.body is Map<String, dynamic>) {
        return ResponseData.fromJson(response.body);
      } else {
        return ResponseData(successful: true, code: 'OK', data: response.body);
      }
    }

    // 7. No Content (204)
    if (response.isNoContent) {
      return ResponseData(successful: true, code: 'NO_CONTENT', data: null);
    }

    // 8. Outros Erros (400, 404, etc) que já extraímos a mensagem lá em cima
    if (serverMessage != null) {
      throw RestError(response, serverMessage);
    }

    // Fallback final
    throw RestError(response, response.statusText ?? 'Erro na requisição (${response.statusCode})');
  }
}