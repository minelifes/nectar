import 'package:nectar/nectar.dart';

class ColumnInfo {
  final String name;
  final ColumnType columnType;
  final dynamic defaultValue;
  final int length;
  final bool unique;
  final bool nullable;
  final bool isKey;
  final bool isAutoIncrement;

  const ColumnInfo({
    required this.name,
    required this.columnType,
    this.defaultValue = null,
    this.isKey = false,
    this.isAutoIncrement = false,
    this.unique = false,
    this.nullable = false,
    this.length = 0,
  });
}
