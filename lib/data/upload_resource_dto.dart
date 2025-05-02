import 'dart:typed_data';

class UploadResourceDTO {
  final String name;
  final String? description;
  final String path;
  final Uint8List bytes;

  UploadResourceDTO({
    required this.name,
    this.description,
    required this.path,
    required this.bytes
  });
}