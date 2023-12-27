import 'package:analyzer/dart/element/element.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';

import 'orm_utils.dart';

class OrmSerializer {
  final ClassInspector inspector;
  const OrmSerializer(this.inspector);

  String _fieldFromRow(FieldElement e) {
    final referenceClass =
        getFieldValueFromRelationAnnotation(e, "referenceClass");
    if (referenceClass == null) {
      return '''
        ${e.name} = result['${inspector.tableName}_${getFieldNameFromOrmAnnotation(e)}'];
      ''';
    }

    return '''
      ${e.name} = ${referenceClass.replaceFirst("_", "")}()..fromRow(result);
    ''';
  }

  String generate() {
    return '''
    
       @override
       List<String> get columns => [${inspector.fields.map((e) => getFieldNameFromOrmAnnotation(e).wrapWith()).join(", ")}];
      
       @override
       String get tableName => "${inspector.tableName}";
       
        @override  
        void fromRow(Map result) {
            ${inspector.fields.map(_fieldFromRow).join("\n ")}
        }
        
       static ${inspector.name}Query query() => ${inspector.name}Query();
       
       Future<${inspector.name}?> save() async => 
            ${inspector.name}InsertClause(this, () => ${inspector.name}()).insert();
          
       Future<${inspector.name}?> update() async => 
            ${inspector.name}InsertClause(this, () => ${inspector.name}()).update();
    ''';
  }
}
