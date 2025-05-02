extension MapExtensions on Map {
  Map<dynamic, dynamic> removeNullValues() {
    return Map.fromEntries(entries.where((e) => e.value != null));
  }

  Map<String, dynamic> toQueryParams() {
    return removeNullValues().map((key, value) {
      dynamic newValue;

      if (value is List<String> || value is String) {
        newValue = value;
      } else {
        newValue = value.toString();
      }

      return MapEntry(key, newValue);
    });
  }
}