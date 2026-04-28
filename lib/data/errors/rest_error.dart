import 'dart:convert';

import 'package:get/get.dart';

class RestError implements Exception {
  final Response response;

  final String? message;

  RestError(this.response, [this.message]);

  @override
  String toString() {
    return '''
    an error occurred while processing the request:
    $message
    
    response status code: ${response.status.code}
    response body: ${response.bodyString}
    response headers: ${jsonEncode(response.headers)}
    ''';
  }
}