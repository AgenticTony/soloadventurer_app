/// Type-safe JSON parsing helpers.
///
/// Use these instead of direct casting to avoid runtime errors:
/// ```dart
/// // ❌ Unsafe:
/// final id = data['id'] as int?;
///
/// // ✅ Safe:
/// final id = JsonHelpers.parseInt(data['id']);
/// ```
class JsonHelpers {
  JsonHelpers._();

  /// Safely parse an int from dynamic data.
  ///
  /// Handles: int, String (parseable), double, null
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  /// Parse int with a default value if null or invalid.
  static int parseIntOrDefault(dynamic value, {int defaultValue = 0}) {
    return parseInt(value) ?? defaultValue;
  }

  /// Safely parse a double from dynamic data.
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse double with a default value.
  static double parseDoubleOrDefault(dynamic value, {double defaultValue = 0.0}) {
    return parseDouble(value) ?? defaultValue;
  }

  /// Safely parse a String from dynamic data.
  static String? parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Parse String with a default value.
  static String parseStringOrDefault(dynamic value, {String defaultValue = ''}) {
    return parseString(value) ?? defaultValue;
  }

  /// Safely parse a bool from dynamic data.
  ///
  /// Handles: bool, int (0/1), String ('true'/'false'/'1'/'0')
  static bool? parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  /// Parse bool with a default value.
  static bool parseBoolOrDefault(dynamic value, {bool defaultValue = false}) {
    return parseBool(value) ?? defaultValue;
  }

  /// Safely parse a DateTime from dynamic data.
  ///
  /// Handles: DateTime, String (ISO 8601), int (milliseconds since epoch)
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// Safely parse a List with a mapper function.
  ///
  /// Example:
  /// ```dart
  /// final ids = JsonHelpers.parseList<int>(
  ///   data['ids'],
  ///   (e) => JsonHelpers.parseIntOrDefault(e),
  /// );
  /// ```
  static List<T>? parseList<T>(dynamic value, T Function(dynamic) mapper) {
    if (value == null) return null;
    if (value is! List) return null;
    try {
      return value.map((e) => mapper(e)).toList();
    } catch (_) {
      return null;
    }
  }

  /// Parse List with empty default.
  static List<T> parseListOrEmpty<T>(dynamic value, T Function(dynamic) mapper) {
    return parseList(value, mapper) ?? [];
  }

  /// Safely parse a Map<String, dynamic>.
  static Map<String, dynamic>? parseMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Parse Map with empty default.
  static Map<String, dynamic> parseMapOrEmpty(dynamic value) {
    return parseMap(value) ?? {};
  }
}
