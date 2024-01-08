/// Extensions of a string
extension StringExtension on String {
  /// Capitalizes the first letter of a given string
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}