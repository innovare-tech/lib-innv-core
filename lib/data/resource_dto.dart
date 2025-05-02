import 'dart:typed_data';

class ResourceDTO {
  final String filename;
  final Uint8List bytes;

  ResourceDTO(this.filename, this.bytes);
}