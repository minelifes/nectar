interface class Model<T> {
  List<String> get columns => [];
  String get tableName => "";

  void fromRow(Map result) {}
}
