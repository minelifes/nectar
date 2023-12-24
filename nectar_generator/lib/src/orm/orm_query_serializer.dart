import 'package:nectar_generator/src/core/class_inspector.dart';

class OrmQuerySerializer {
  final ClassInspector inspector;
  const OrmQuerySerializer(this.inspector);

  String generate() {
    return '''
      class ${inspector.name}Query extends Query<${inspector.name}> {
        ${inspector.name}Query() : super("${inspector.tableName}");
      
        @override
        Test instanceOfT() => ${inspector.name}();
      
        @override
        ${inspector.name}SelectClause select({List<String>? fields}){
          if(fields != null){
            model.fields = fields.join(", ");
          }
          return ${inspector.name}SelectClause(model, instanceOfT);
        }
      }
    ''';
  }
}
