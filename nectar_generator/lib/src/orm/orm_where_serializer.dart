import 'package:analyzer/dart/element/element.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/orm/orm_utils.dart';

class OrmWhereSerializer {
  final ClassInspector inspector;
  OrmWhereSerializer(this.inspector);

  String generate() {
    return '''
      class ${inspector.name}WhereClause extends WhereClause<${inspector.name}> {
        ${inspector.name}WhereClause(super.model, super.instanceOfT);
        
        ${inspector.fields.map((e) => _fieldToWhere(e)).join("\n\n")}
        
        ${inspector.name}WhereClause customField(String key, value, {operator = "="}) {
          model.where[key] = [operator, value];
          return this;
        }
      }
    ''';
  }

  String _fieldToWhere(FieldElement field) {
    final type = _fieldToType(field);
    if (type == null) return "";
    return '''
        ${inspector.name}WhereClause ${field.name}($type value, {operator = "="}) {
          model.where["${getFieldNameFromOrmAnnotation(field)}"] = [operator, value];
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
