import 'package:innovare_core/data/rest_options.dart';

abstract class RestContext {
  String uri();
  RestOptions? options();

  String buildCompleteUri(String path) {
    return "${uri()}$path";
  }
}