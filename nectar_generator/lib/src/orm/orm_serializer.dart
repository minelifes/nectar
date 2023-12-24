import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';

import 'orm_utils.dart';

class OrmSerializer {
  final ClassInspector inspector;
  const OrmSerializer(this.inspector);

  String generate() {
    return '''
    
       @override
       List<String> get columns => [${inspector.fields.map((e) => getFieldNameFromOrmAnnotation(e).wrapWith()).join(", ")}];
      
       @override
       String get tableName => "${inspector.tableName}";
       
        @override  
        void fromRow(Map result) {
            ${inspector.fields.map((e) => "${e.name} = result[${getFieldNameFromOrmAnnotation(e).wrapWith()}]").join(";\n ")};
        }
        
       static ${inspector.name}Query query() => ${inspector.name}Query();
       
       Future<${inspector.name}?> save() async => 
            ${inspector.name}InsertClause(this, () => Test()).insert();
          
       Future<${inspector.name}?> update() async => 
            ${inspector.name}InsertClause(this, () => Test()).update();
    ''';
  }
}
