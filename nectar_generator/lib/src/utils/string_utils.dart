extension StringExtension on String {
  String removePrefix() => replaceFirst("_", "");
  String wrapWith({String symbol = '"'}) => '$symbol$this$symbol';
}
