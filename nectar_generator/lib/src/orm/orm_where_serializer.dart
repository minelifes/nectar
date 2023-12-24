import 'package:analyzer/dart/element/element.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/orm/orm_utils.dart';

class OrmWhereSerializer {
  final ClassInspector inspector;
  const OrmWhereSerializer(this.inspector);

  String generate() {
    return '''
      class ${inspector.name}WhereClause extends WhereClause<${inspector.name}> {
        ${inspector.name}WhereClause(super.model, super.instanceOfT);
        
        ${inspector.fields.map((e) => _fieldToWhere(e)).join("\n\n")}
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

  String? _fieldToType(FieldElement field) {
    final type = field.type.getDisplayString(withNullability: false);
    if (type != "int" ||
        type != "double" ||
        type != "float" ||
        type != "String" ||
        type != "bool" ||
        type != "DateTime") return type;
    return null;
  }
}
