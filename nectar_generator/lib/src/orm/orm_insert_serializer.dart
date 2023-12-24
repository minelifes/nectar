import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';

import 'orm_utils.dart';

class OrmInsertSerializer {
  final ClassInspector inspector;
  const OrmInsertSerializer(this.inspector);

  String generate() {
    return '''      
      class ${inspector.name}InsertClause extends InsertClause<${inspector.name}> {
        ${inspector.name}InsertClause(super.model, super.instanceOfT);
      
        @override
        Map<String, dynamic> toInsert() => {
           ${inspector.fields.map((e) => "${getFieldNameFromOrmAnnotation(e).wrapWith()}: model.${e.name}").join(",\n ")},

          };
      }
    ''';
  }
}
