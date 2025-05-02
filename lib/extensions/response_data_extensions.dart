import 'package:innovare_core/data/paginated_response_dto.dart';
import 'package:innovare_core/data/rest_connect.dart';

extension ResponseDataExtensions on ResponseData {
  PaginatedResponseDTO<T> paginated<T>(T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponseDTO.fromJson(data, fromJson);
  }

  List<T> asList<T>(T Function(Map<String, dynamic>) fromJson) {
    final dynamicList = data as List<dynamic>;

    return dynamicList.map((e) => fromJson(e)).toList();
  }

  T as<T>(T Function(Map<String, dynamic>) fromJson) {
    return fromJson(data);
  }

  String asString() {
    return data as String;
  }

  void asVoid() {
    return;
  }
}

extension FutureResponseDataExtensions on Future<ResponseData> {
  Future<PaginatedResponseDTO<T>> paginated<T>(T Function(Map<String, dynamic>) fromJson) async {
    final response = await this;
    return response.paginated(fromJson);
  }

  Future<List<T>> asList<T>(T Function(Map<String, dynamic>) fromJson) async {
    final response = await this;
    return response.asList(fromJson);
  }

  Future<T> as<T>(T Function(Map<String, dynamic>) fromJson) async {
    final response = await this;
    return response.as(fromJson);
  }

  Future<String> asString() async {
    final response = await this;
    return response.data as String;
  }

  Future<void> asVoid() async {
    await this;
  }
}