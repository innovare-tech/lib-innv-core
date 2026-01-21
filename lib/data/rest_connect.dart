import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart'; // Para kDebugMode
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

// --- Extensions Úteis (Mantidas e expandidas) ---
extension GetResponseExtensions on Response {
  bool get isBadRequest => status.code == HttpStatus.badRequest;
  bool get isUnauthorized => status.code == HttpStatus.unauthorized;
  bool get isForbidden => status.code == HttpStatus.forbidden;
  bool get isInternalServerError => status.code == HttpStatus.internalServerError;
  bool get isCreated => status.code == HttpStatus.created;
  bool get isNotFound => status.code == HttpStatus.notFound;
  bool get isNoContent => status.code == HttpStatus.noContent;
}

// --- Wrapper de Resposta Padronizada ---
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

  String get message => detailedErrorMessage ?? errorMessage  ?? 'Erro desconhecido';
}

abstract class RestConnect<T extends RestContext> extends GetConnect {
  final T context;
  final AuthManager? _authManager;
  final _logger = Logger();

  // Controle de concorrência para o refresh token
  bool _isRefreshing = false;

  RestOptions get defaultOptions => RestOptions(
    timeout: const Duration(seconds: 30),
  );

  RestConnect(this.context, [this._authManager]) {
    httpClient.baseUrl = context.uri();

    final restOptions = context.options().orElse(defaultOptions);
    httpClient.timeout = restOptions.timeout.orElse(const Duration(seconds: 30));

    // 1. Logging de Requisição
    httpClient.addRequestModifier<dynamic>((request) async {
      if (kDebugMode) _logger.i('--> ${request.method} ${request.url}');
      return request;
    });

    // 2. Logging de Resposta
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

    // 3. Autenticação Automática (Refresh Token) CORRIGIDO 🚀
    // O método correto é addAuthenticator. Ele é chamado quando a resposta é 401.
    httpClient.addAuthenticator<dynamic>((Request request) async {
      _logger.w('[AUTH] 401 detectado. Iniciando tentativa de refresh...');

      if (_authManager == null) return request;

      // Evita loops ou chamadas concorrentes
      if (_isRefreshing) return request;
      _isRefreshing = true;

      try {
        // Implemente este método no seu AuthManager para bater na API de refresh
        final success = await _authManager.refreshToken();

        if (success) {
          _logger.i('[AUTH] Token renovado com sucesso.');
          final newToken = _authManager.getAccessToken();

          // Atualiza o header da requisição que falhou e retorna ela para ser refeita
          request.headers['Authorization'] = 'Bearer $newToken';
          return request;
        } else {
          _logger.e('[AUTH] Falha na renovação. Logout forçado.');
          _authManager.logout();
          return request; // Retorna request original para propagar o erro 401
        }
      } catch (e) {
        _logger.e('[AUTH] Erro crítico durante refresh: $e');
        return request;
      } finally {
        _isRefreshing = false;
      }
    });

    // Limite de tentativas para evitar loop infinito de 401
    httpClient.maxAuthRetries = 1;
  }

  // --- Métodos HTTP Refatorados com Tratamento Centralizado ---

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

  // --- Upload ---
  Future<ResponseData> doPOSTResource(String uri, UploadResourceDTO resource, {
    Map<String, dynamic>? params
  }) async {
    final formData = FormData({
      "file": MultipartFile(resource.bytes, filename: resource.name)
    });
    // Reutiliza doPOST para ganhar o tratamento de erro e refresh token grátis
    return await doPOST(uri, body: formData, params: params);
  }

  // --- Upload Múltiplo (Para listas de arquivos) ---
  Future<ResponseData> doPOSTResources(String uri, List<UploadResourceDTO> resources, {
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

  // --- Download (Com Refresh Manual pois usa http.Client) ---
  Future<ResourceDTO> doGETResource(String uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? contentType,
    bool requiresAuth = true,
  }) async {
    final baseUrl = httpClient.baseUrl ?? '';
    final finalUri = Uri.parse(baseUrl + uri).replace(queryParameters: params);

    final requestHeaders = _completeHeaders(headers, requiresAuth) ?? {};
    // Adicione header fixo se necessário, ex: requestHeaders['X-App-Token'] = ...

    final client = http.Client();
    var response = await client.get(finalUri, headers: requestHeaders);

    // Lógica manual de Refresh Token para http.Client
    if (response.statusCode == HttpStatus.unauthorized && _authManager != null) {
      _logger.w('[Download] 401 no download. Tentando refresh manual...');
      final success = await _authManager.refreshToken();
      if (success) {
        // Atualiza header e tenta de novo
        final newToken = _authManager.getAccessToken();
        requestHeaders['Authorization'] = 'Bearer $newToken';
        response = await client.get(finalUri, headers: requestHeaders);
      }
    }

    if (response.statusCode == HttpStatus.ok) {
      final contentDisposition = response.headers["content-disposition"];
      final fileName = _extractFileName(contentDisposition);
      return ResourceDTO(fileName, response.bodyBytes);
    }

    throw RestError(
        Response(statusCode: response.statusCode, statusText: response.reasonPhrase),
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

  Map<String, String>? _completeHeaders(Map<String, String>? currentHeaders, bool requiresAuth) {
    final headers = currentHeaders ?? {};
    if (requiresAuth) {
      if (_authManager == null) throw Exception('AuthManager não configurado.');

      final token = _authManager.getAccessToken();
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- Tratamento de Erros Elegante ---
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

    // 3. Acesso Negado (401/403)
    if (response.isUnauthorized) {
      // Se chegou aqui, o addAuthenticator falhou ou esgotou tentativas
      throw RestError(response, 'Sessão expirada. Faça login novamente.');
    }
    if (response.isForbidden) {
      throw RestError(response, 'Você não tem permissão para realizar esta ação.');
    }

    // 4. Sucesso (2xx)
    if (response.isOk || response.isCreated) {
      if (response.body == null) {
        return ResponseData(successful: true, code: 'OK', data: null);
      }

      // Tenta parsear para nosso formato ResponseData
      if (response.body is Map<String, dynamic>) {
        return ResponseData.fromJson(response.body);
      } else {
        // Fallback para APIs que retornam JSON puro
        return ResponseData(successful: true, code: 'OK', data: response.body);
      }
    }

    // 5. No Content (204)
    if (response.isNoContent) {
      return ResponseData(successful: true, code: 'NO_CONTENT', data: null);
    }

    // 6. Erros de Negócio (400, 404, etc)
    // Tenta extrair mensagem amigável do backend
    try {
      if (response.body is Map<String, dynamic>) {
        final errorData = ResponseData.fromJson(response.body);
        throw RestError(response, errorData.message);
      }
    } catch (_) {}

    // Fallback final
    throw RestError(response, response.statusText ?? 'Erro na requisição (${response.statusCode})');
  }
}