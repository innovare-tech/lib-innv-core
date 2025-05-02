import 'package:http/http.dart';

extension HttpResponseExtensions on Response {
  String filenameFromHeader() {
    final contentDisposition = headers["content-disposition"];

    if (contentDisposition != null) {
      RegExp regex = RegExp(r'filename="(.+)"');
      Match? match = regex.firstMatch(contentDisposition);
      if (match != null) {
        return match.group(1) ?? "file";
      }
    }

    return "file";
  }
}