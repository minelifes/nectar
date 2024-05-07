import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:nectar/nectar.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/orm/orm_utils.dart';

class OrmWhereSerializer {
  final ClassInspector inspector;
  OrmWhereSerializer(this.inspector);

  Future<String> generate() async {
    var names = await Future.wait(inspector.fields.map(_fieldNames));
    List<(FieldElement field, String? referenceClass,  String? customName, String? customType)> items = [];
    for (var element in names) {
      if(element.$3 == null){
        items.add(element);
        continue;
      }
      final f = items.firstWhereOrNull((e) => e.$3 == element.$3);
      if(f == null) items.add(element);
    }

    List<String> results = items.mapIndexed((_, e) => _fieldToWhere(e.$1, e.$2, e.$3, e.$4)).toList();
    return '''
      class ${inspector.name}WhereClause extends WhereClause<${inspector.name}> {
        ${inspector.name}WhereClause(super.model, super.instanceOfT);
        
        ${results.join("\n\n")}
        
        ${inspector.name}WhereClause customField(String key, value, {operator = "=", condition="AND"}) {
          model.where[key] = [operator, value, condition];
          return this;
        }
        
        ${inspector.name}WhereClause customWhere(String where) {
          model.where["_SQL"] = where;
          return this;
        }
      }
    ''';
  }

  Future <(FieldElement field, String? referenceClass,  String? customName, String? customType)> _fieldNames(FieldElement field) async {
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

    return (field, referenceClass, customName, customType);
  }

  String _fieldToWhere(FieldElement field, String? referenceClass,  String? customName, String? customType) {
    return '''
        ${inspector.name}WhereClause ${customName != null ? "${referenceClass!.toLowerCase().replaceFirst("_", "")}${customName.capitalize()}" : field.name}(${customName != null ? "$customType" : field.type.toString()} value, {operator = "=", condition="AND"}) {
          model.where["${inspector.tableName}.${getFieldNameFromOrmAnnotation(field)}"] = [operator, value, condition];
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
