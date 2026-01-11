/// Extension methods for [String]
library;

/// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  /// Returns the string with the first letter capitalized
  ///
  /// Example:
  /// ```dart
  /// 'hello'.toCapitalized(); // 'Hello'
  /// 'HELLO'.toCapitalized(); // 'HELLO'
  /// ''.toCapitalized(); // ''
  /// ```
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : this;
}
