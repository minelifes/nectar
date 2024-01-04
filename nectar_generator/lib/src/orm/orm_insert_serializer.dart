import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';

import 'orm_utils.dart';

class OrmInsertSerializer {
  final ClassInspector inspector;
  const OrmInsertSerializer(this.inspector);

  Future<String> _getForeignValueFromReferenceClass(
      FieldElement element, ElementAnnotation ann) async {
    final referenceClass =
        getFieldFromAnnotation(ann, "referenceClass")?.toStringValue();
    final foreignKey =
        getFieldFromAnnotation(ann, "foreignKey")?.toStringValue();
    if (foreignKey == "id") return "id";
    if (referenceClass == null || foreignKey == null) return "";
    final clazz = await getClassInfo(inspector, referenceClass);
    if (clazz == null) return "";
    return clazz.fields
            .firstWhereOrNull((element) =>
                getFieldNameFromOrmAnnotation(element) == foreignKey)
            ?.name ??
        "";
  }

  Future<String> _getFieldData(FieldElement element) async {
    var e = getColumnAnnotation(element);
    if (e != null) {
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name}";
    }
    e = getIdAnnotation(element);
    if (e != null) {
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name} ?? generateUUID()";
    }
    e = getEnumColumnAnnotation(element);
    if (e != null) {
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name}?.toString()";
    }
    e = getOneToOneAnnotation(element);
    if (e != null) {
      final fieldName = await _getForeignValueFromReferenceClass(element, e);
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name}${fieldName.isNotEmpty ? "?.$fieldName" : ""}";
    }
    e = getManyToOneAnnotation(element);
    if (e != null) {
      final fieldName = await _getForeignValueFromReferenceClass(element, e);
      return "${getFieldNameFromOrmAnnotation(element).wrapWith()}: model.${element.name}${fieldName.isNotEmpty ? "?.$fieldName" : ""}";
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
        Map<String, dynamic> toInsert() => {
           ${list.where((element) => element.isNotEmpty).join(",\n ")},

          };
      }
    ''';
  }
}
