import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:nectar/nectar.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'orm_utils.dart';

class OrmMigrationSerializer {
  final ClassInspector inspector;
  const OrmMigrationSerializer(this.inspector);

  Future<String> _getMysqlTypeFromDartObject(
      FieldElement element, int length, bool isKey) async {
    String fieldType =
        element.type.getDisplayString(withNullability: false).toLowerCase();
    switch (fieldType) {
      case 'int':
        return "ColumnType.integer";
      case 'double':
        return "ColumnType.double";
      case 'float':
        return "ColumnType.float";
      case 'string':
        return (length < 256 && length > 0) || isKey
            ? "ColumnType.varchar"
            : "ColumnType.text";
      case 'bool':
        return "ColumnType.bool";
      case 'enum':
        return "ColumnType.varchar";
      case 'datetime':
        return "ColumnType.timestamp";
      default:
        if (element.computeConstantValue()?.type is Enum) {
          return "ColumnType.varchar";
        }
        if (element.computeConstantValue()?.type is DateTime) {
          return "ColumnType.timestamp";
        }
        final rel = getRelationAnnotation(element);
        final ref =
            getFieldFromAnnotation(rel, "referenceClass")?.toStringValue();
        final foreignKey =
            getFieldFromAnnotation(rel, "foreignKey")?.toStringValue();
        if (ref == null || foreignKey == null) return "ColumnType.integer";
        final c = await getClassInfo(inspector, ref);
        final data = c?.fields.firstWhereOrNull((element) {
          final col = getFieldNameFromOrmAnnotation(element);
          return col == foreignKey;
        });
        if (data == null) return "ColumnType.integer";
        return await _getMysqlTypeFromDartObject(data, length, true);
      //
      //
      // return _getMysqlTypeFromDartObject();
    }
  }

  Future<String> _getFieldElementType(
      FieldElement element, int length, bool isKey) async {
    final columnType =
        getFieldValueFromColumn(element, "columnType")?.toStringValue();
    if (columnType != null) {
      return "ColumnType.$columnType";
    }
    return await _getMysqlTypeFromDartObject(element, length, isKey);
  }

  bool _isFieldContainsColumnOrIdOrRelation(FieldElement element) {
    var e = getColumnAnnotation(element);
    if (e != null) return true;
    e = getIdAnnotation(element);
    if (e != null) return true;
    e = getOneToOneAnnotation(element);
    if (e != null) return true;
    e = getManyToOneAnnotation(element);
    if (e != null) return true;
    e = getEnumColumnAnnotation(element);
    return e != null;
  }

  Future<String> getColumnInfoFromFieldElement(FieldElement element) async {
    final includeField = _isFieldContainsColumnOrIdOrRelation(element);
    if (!includeField) return "";

    final name = getFieldNameFromOrmAnnotation(element);
    final defaultValue =
        getRawFieldValueFromOrmAnnotation(element, "defaultValue")
            ?.toStringValue();
    final isKey = getIdAnnotation(element) != null;
    final isAutoIncrement = getAutoIncrementAnnotation(element) != null;
    final unique =
        getRawFieldValueFromOrmAnnotation(element, "unique")?.toBoolValue();
    final nullable =
        getRawFieldValueFromOrmAnnotation(element, "nullable")?.toBoolValue();
    final length =
        getRawFieldValueFromOrmAnnotation(element, "length")?.toIntValue() ?? 0;
    final columnType = isAutoIncrement
        ? "ColumnType.integer"
        : await _getFieldElementType(element, length, isKey);

    final id =
        inspector.fields.where((e) => getIdAnnotation(e) != null).firstOrNull;
    if (id == null) {
      throw Exception(
          "${inspector.classElement.name} don't have any filed with @Id annotation");
    }
    final idName = getFieldNameFromOrmAnnotation(id);

    if (!isKey && name == idName) return "";

    return ''' 
      ColumnInfo(
        name: '$name', 
        columnType: $columnType, 
        defaultValue: $defaultValue,
        isKey: $isKey, 
        isAutoIncrement: $isAutoIncrement, 
        unique: ${isKey ? false : unique ?? false}, 
        nullable: ${isKey ? false : nullable ?? false}, 
        length: ${length ?? 0},
      )
    ''';
  }

  Future<String> generate() async {
    List<String> list = await Future.wait(inspector.fields
        .map((e) async => await getColumnInfoFromFieldElement(e))
        .toList());
    return '''      
      class ${inspector.name}Migration extends Migration {
        ${inspector.name}Migration(super.tableName);
      
        @override
        List<ColumnInfo> get columns => [
          ${list.where((e) => e.isNotEmpty).join(", ")}
        ];

      }
    ''';
  }
}
