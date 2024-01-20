interface class Model {
  List<String> get columns => [];
  String get tableName => "";
  String get primaryKeyName => "";

  void fromRow(Map result, Map? allResponse) {}
}
