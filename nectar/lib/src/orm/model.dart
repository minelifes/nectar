interface class Model {
  List<String> get columns => [];
  String get tableName => "";

  void fromRow(Map result) {}
}
