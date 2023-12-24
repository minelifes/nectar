import 'package:nectar_generator/src/core/class_inspector.dart';

class OrmSelectSerializer {
  final ClassInspector inspector;
  const OrmSelectSerializer(this.inspector);

  String generate() {
    return '''
      class ${inspector.name}SelectClause extends SelectClause<${inspector.name}> {
        ${inspector.name}SelectClause(super.model, super.instanceOfT);
      
        @override
        ${inspector.name}WhereClause where() => ${inspector.name}WhereClause(model, instanceOfT);
        
        
      }
    ''';
  }
}
