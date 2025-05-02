class PaginatedResponseDTO<T> {
  final int page;
  final int total;
  final int totalPages;
  final int offset;
  final List<T> data;

  factory PaginatedResponseDTO({
    required int page,
    required int total,
    required int totalPages,
    required int offset,
    required List<T> data
  }) {
    return PaginatedResponseDTO._(
      page: page,
      total: total,
      totalPages: totalPages,
      offset: offset,
      data: data
    );
  }

  PaginatedResponseDTO._({
    required this.page,
    required this.total,
    required this.totalPages,
    required this.offset,
    required this.data
  });

  factory PaginatedResponseDTO.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) dataMapper) {
    return PaginatedResponseDTO(
      page: json['page'],
      total: json['total'],
      totalPages: json['totalPages'],
      offset: json['offset'],
      data: (json['data'] as List).map((e) => dataMapper(e)).toList()
    );
  }

  factory PaginatedResponseDTO.empty() {
    return PaginatedResponseDTO(
      page: 1,
      total: 0,
      totalPages: 1,
      offset: 0,
      data: []
    );
  }
}