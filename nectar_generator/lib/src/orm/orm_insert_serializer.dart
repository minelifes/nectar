import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';

import 'orm_utils.dart';

class FieldInfo {
  final bool isNullable;
  final String name;

  const FieldInfo({required this.name, this.isNullable = false});
}

class OrmInsertSerializer {
  final ClassInspector inspector;
  const OrmInsertSerializer(this.inspector);

  Future<FieldInfo> _getForeignValueFromReferenceClass(
      FieldElement element, ElementAnnotation ann) async {
    final referenceClass =
        getFieldFromAnnotation(ann, "referenceClass")?.toStringValue();

    final foreignKey =
        getFieldFromAnnotation(ann, "foreignKey")?.toStringValue();
    final nullable = getFieldFromAnnotation(ann, "nullable")?.toBoolValue();
    if (foreignKey == "id") {
      return FieldInfo(name: "id", isNullable: nullable ?? false);
    }
    if (referenceClass == null || foreignKey == null) {
      return FieldInfo(name: "");
    }
    final clazz = await getClassInfo(inspector, referenceClass);
    if (clazz == null) return FieldInfo(name: "");
    final foreignField = clazz.fields.firstWhereOrNull(
        (element) => getFieldNameFromOrmAnnotation(element) == foreignKey);
    if (foreignField == null) return FieldInfo(name: "");
    return FieldInfo(name: foreignField.name, isNullable: nullable ?? false);
  }

  Future<String> _getFieldData(FieldElement element) async {
    final isKey = getIdAnnotation(element) != null;
    final name = getFieldNameFromOrmAnnotation(element);
    final id =
        inspector.fields.where((e) => getIdAnnotation(e) != null).firstOrNull;
    if (id == null) {
      throw Exception(
          "${inspector.classElement.name} don't have any filed with @Id annotation");
    }
    final idName = getFieldNameFromOrmAnnotation(id);
    if (!isKey && name == idName) return "";

    var e = getColumnAnnotation(element);
    if (e != null) {
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: ${element.computeConstantValue()?.type is DateTime ? "model.${element.name}.toIso8601String()" : "model.${element.name}"}";
    }
    e = getIdAnnotation(element);
    if (e != null) {
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name} ${getUUIdAnnotation(element) != null ? "?? generateUUID()" : ""} ";
    }
    e = getEnumColumnAnnotation(element);
    if (e != null) {
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name}${e.computeConstantValue()?.isNull ?? true ? "?" : ""}.name";
    }
    e = getOneToOneAnnotation(element);
    if (e != null) {
      final fieldName = await _getForeignValueFromReferenceClass(element, e);
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name}${fieldName.name.isNotEmpty ? "${fieldName.isNullable ? "?" : ""}.${fieldName.name}" : ""}";
    }
    e = getManyToOneAnnotation(element);
    if (e != null) {
      final fieldName = await _getForeignValueFromReferenceClass(element, e);
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name}${fieldName.name.isNotEmpty ? "${fieldName.isNullable ? "?" : ""}.${fieldName.name}" : ""}";
    }
    return "";
    // e = getOneToManyAnnotation(element);
    // if (e == null) return "";
    // final fieldName = await _getForeignValueFromReferenceClass(element, e);
    // return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name}${fieldName.isNotEmpty ? ".$fieldName" : ""}";
  }

  Future<String> generate() async {
    final list = await Future.wait(
        inspector.fields.map((e) async => await _getFieldData(e)));
    return '''      
      class ${inspector.name}InsertClause extends InsertClause<${inspector.name}> {
        ${inspector.name}InsertClause(super.model, super.instanceOfT);
        
        @override
        Future<${inspector.name}?> selectOne(String primaryKeyName, dynamic value) async => (await ${inspector.name}Query().select().where().addCustom('${inspector.tableName}.\$primaryKeyName', value).list()).firstOrNull;
      
        @override
        Map<String, dynamic> toInsert() => {
           ${list.where((element) => element.isNotEmpty).join(",\n ")},

          };
      }
    ''';
  }
}
