import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:innovare_core/data/auth_manager.dart';
import 'package:innovare_core/data/errors/rest_error.dart';
import 'package:innovare_core/data/errors/unknown_rest_error.dart';
import 'package:innovare_core/data/resource_dto.dart';
import 'package:innovare_core/data/rest_context.dart';
import 'package:innovare_core/data/rest_options.dart';
import 'package:innovare_core/data/upload_resource_dto.dart';
import 'package:innovare_core/extensions/generic_extensions.dart';
import 'package:logger/logger.dart';

extension GetResponseExtensions on Response {
  bool get isBadRequest => status.code == HttpStatus.badRequest;
  bool get isUnauthorized => status.code == HttpStatus.unauthorized;
  bool get isInternalServerError => status.code == HttpStatus.internalServerError;
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
      successful: json['successful'],
      errorMessage: json['errorMessage'],
      detailedErrorMessage: json['detailedErrorMessage'],
      code: json['code'],
      data: json['data']
    );
  }

  String get message => detailedErrorMessage ?? errorMessage  ?? 'Unknown error';
}

abstract class RestConnect<T extends RestContext> extends GetConnect {
  final T context;
  final AuthManager? _authManager;

  RestOptions get defaultOptions => RestOptions(
    timeout: 30.seconds,
  );

  final _logger = Logger();

  RestConnect(this.context, [this._authManager]) {
    httpClient.baseUrl = context.uri();

    final restOptions = context.options().orElse(defaultOptions);
    httpClient.timeout = restOptions.timeout.orElse(30.seconds);
    //
    // httpClient.addRequestModifier<dynamic>((request) async {
    //   _logger.i('[REQUEST]');
    //   _logger.i('--> ${request.method} ${request.url}');
    //   if (request.headers.isNotEmpty) {
    //     _logger.i('Headers: ${request.headers}');
    //   }
    //   // if (request.body != null) {
    //   //   _logger.i('Body: ${request.body}');
    //   // }
    //   return request;
    // });
  }

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

    return _assertResponse(response);
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

    return _assertResponse(response);
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

    return _assertResponse(response);
  }

  Future<ResponseData> doPOSTResource(String uri, UploadResourceDTO resource, {
    Map<String, dynamic>? params
  }) async {
    final formData = FormData({
      "file": MultipartFile(
        resource.bytes,
        filename: resource.name
      )
    });

    return await doPOST(uri, body: formData);
  }

  Future<ResourceDTO> doGETResource(String uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? contentType,
    bool requiresAuth = true,
  }) async {
    final finalUri = Uri.parse(httpClient.baseUrl! + uri).replace(queryParameters: params);

    _logger.i(finalUri);

    final client = http.Client();

    final response = await client.get(finalUri, headers: {
      'Authorization': 'F2C0E700-BEAD-467C-92F9-15A1A5AAD5FB',
    });

    if (response.statusCode == HttpStatus.ok) {
      _logger.i(response.headers);

      final contentDisposition = response.headers["content-disposition"];
      final fileName = _extractFileName(contentDisposition);

      return ResourceDTO(fileName, response.bodyBytes);
    }

    throw FlutterError('Failed to download resource');
  }

  String _extractFileName(String? contentDisposition) {
    if (contentDisposition != null) {
      RegExp regex = RegExp(r'filename="(.+)"');
      Match? match = regex.firstMatch(contentDisposition);
      if (match != null) {
        return match.group(1) ?? "arquivo_desconhecido.zip";
      }
    }
    return "arquivo_desconhecido.zip";
  }

  //
  // Future<Uint8List> _streamToUint8List(Stream<List<int>> stream) async {
  //   List<int> bytes = [];
  //   await for (var chunk in stream) {
  //     bytes.addAll(chunk);
  //   }
  //   return Uint8List.fromList(bytes);
  // }

  Map<String, String>? _completeHeaders(Map<String, String>? currentHeaders, bool requiresAuth) {
    if (currentHeaders == null && !requiresAuth) {
      return null;
    }

    if (requiresAuth && _authManager == null) {
      throw FlutterError('AuthManager is required for this request');
    }

    final headers = currentHeaders ?? {};

    if (requiresAuth) {
      final token = _authManager!.getAccessToken();

      if (token.isEmpty) {
        throw FlutterError('Token is required for this request');
      }

      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  ResponseData _assertResponse(Response response) {
    if (response.isNotFound) {
      _throwsCorrectNotFoundError(response);
    }

    if (response.isNoContent) {
      return ResponseData(
        successful: true,
        code: 'NO_CONTENT',
        data: null
      );
    }

    if (response.isOk || response.isCreated) {
      return _responseToResponseData(response);
    }

    if (response.isInternalServerError) {
      throw UnknownRestError(response);
    }

    final responseData = _responseToResponseData(response);

    throw RestError(response, responseData.message);
  }

  ResponseData _responseToResponseData(Response response) {
    return ResponseData.fromJson(response.body);
  }

  void _throwsCorrectNotFoundError(Response response) {
    final body = response.body;

    if (body is Map<String, dynamic>) {
      final isResponseData = body.containsKey('successful') &&
        body.containsKey('errorMessage') &&
        body.containsKey('code');

      if (isResponseData) {
        final responseData = ResponseData.fromJson(body);
        throw RestError(response, responseData.message);
      }

      final errorMessage = body['errorMessage'] ?? 'Unknown error';
      throw RestError(response, errorMessage);
    } else {
      throw RestError(response, 'Unknown error');
    }
  }
}