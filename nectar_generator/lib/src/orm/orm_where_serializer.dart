import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:nectar/nectar.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/orm/orm_utils.dart';
import 'package:source_gen/source_gen.dart';

class OrmWhereSerializer {
  final ClassInspector inspector;
  OrmWhereSerializer(this.inspector);

  Future<String> generate() async {
    List<String> results =
        await Future.wait(inspector.fields.map(_fieldToWhere));
    return '''
      class ${inspector.name}WhereClause extends WhereClause<${inspector.name}> {
        ${inspector.name}WhereClause(super.model, super.instanceOfT);
        
        ${results.join("\n\n")}
        
        ${inspector.name}WhereClause customField(String key, value, {operator = "="}) {
          model.where[key] = [operator, value];
          return this;
        }
      }
    ''';
  }

  Future<String> _fieldToWhere(FieldElement field) async {
    final referenceClass =
        getFieldValueFromRelationAnnotation(field, "referenceClass");

    String? customName;
    String? customType;
    if (referenceClass != null) {
      final clazz = await getClassInfo(inspector, referenceClass);
      if (clazz != null) {
        final idField =
            clazz.fields.firstWhereOrNull((e) => getIdAnnotation(e) != null);
        if (idField != null) {
          final idAnn = getIdAnnotation(idField)!;
          final name =
              idAnn.computeConstantValue()?.getField("name")?.toStringValue();
          customName = name ?? idField.name;
          customType = idField.type.toString();
        }
      }
    }

    return '''
        ${inspector.name}WhereClause ${customName != null ? "${referenceClass!.toLowerCase().replaceFirst("_", "")}${customName.capitalize()}" : field.name}(${customName != null ? "$customType" : field.type.toString()} value, {operator = "="}) {
          model.where["${inspector.tableName}.${getFieldNameFromOrmAnnotation(field)}"] = [operator, value];
          return this;
        }
    ''';
  }

  final _allowedTypes = [
    "int",
    "double",
    "float",
    "String",
    "bool",
    "DateTime"
  ];

  String? _fieldToType(FieldElement field) {
    final type = field.type.getDisplayString(withNullability: false);
    if (_allowedTypes.contains(type)) return type;
    return null;
  }

  // String? _getTypeForIdFromRelationShip(FieldElement field) {
  //   bool isClass = field.getter?.type is Model;
  //   print("isClass: ${isClass}, ${field as ClassElement} ${field.name}");
  //   if (!isClass) return null;
  //   final clazz = field.type.element as ClassElement;
  //   var ann = getManyToOneAnnotation(field) ??
  //       getOneToManyAnnotation(field) ??
  //       getOneToOneAnnotation(field);
  //   if (ann == null) return null;
  //   // var mappedBy =
  //   // ann.computeConstantValue()?.getField("mappedBy")?.toStringValue();
  //   var foreignKey =
  //       ann.computeConstantValue()?.getField("foreignKey")?.toStringValue();
  //   return clazz.fields
  //       .firstWhere((element) => element.name == foreignKey)
  //       .type
  //       .getDisplayString(withNullability: false);
  // }
}
