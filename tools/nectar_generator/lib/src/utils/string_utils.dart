extension StringExtension on String {
  String removePrefix() => this.replaceFirst("_", "");
}
