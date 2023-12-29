import 'package:analyzer/dart/element/element.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';

import '../rest/rest_utils.dart';
import 'orm_utils.dart';

class OrmSerializer {
  final ClassInspector inspector;
  const OrmSerializer(this.inspector);

  Future<String> _fieldFromRow(FieldElement e) async {
    final referenceClass =
        getFieldValueFromRelationAnnotation(e, "referenceClass");
    if (referenceClass == null) {
      return '''
        if(result.containsKey('${inspector.tableName}')){
          ${e.name} = result['${inspector.tableName}']['${inspector.tableName}_${getFieldNameFromOrmAnnotation(e)}'];
        }else{
          ${e.name} = result['${inspector.tableName}_${getFieldNameFromOrmAnnotation(e)}'];
        }
      ''';
    }

    final className = referenceClass.replaceFirst("_", "");
    final clazz = await getClassInfo(inspector, referenceClass);
    if (clazz == null) return "";
    final entity = getAnnotationFromClass(clazz, "Entity");
    if (entity == null) return "";
    final foreignTableName =
        entity.computeConstantValue()!.getField("tableName")!.toStringValue()!;
    if (isFieldList(e)) {
      return '''
        ${e.name} = (result["$foreignTableName"] as List?)?.map((e) => $className()..fromRow(e)).toList() ?? [];
      ''';
    }
    return '''
      final l = (result["$foreignTableName"] as List?);
      ${e.name} = (l == null || l.isEmpty == true) ? ${referenceClass.replaceFirst("_", "")}() : ${referenceClass.replaceFirst("_", "")}()..fromRow(l!.first);
    ''';
  }

  Future<String> generate() async {
    List<String> fields = await Future.wait(
        inspector.fields.map((e) async => await _fieldFromRow(e)));
    return '''
    
       @override
       List<String> get columns => [${inspector.fields.map((e) => getFieldNameFromOrmAnnotation(e).wrapWith()).join(", ")}];
      
       @override
       String get tableName => "${inspector.tableName}";
       
        @override  
        void fromRow(Map result) {
            ${fields.join("\n ")}
        }
        
       static ${inspector.name}Query query() => ${inspector.name}Query();
       
       Future<${inspector.name}?> save() async => 
            ${inspector.name}InsertClause(this, () => ${inspector.name}()).insert();
          
       Future<${inspector.name}?> update() async => 
            ${inspector.name}InsertClause(this, () => ${inspector.name}()).update();
    ''';
  }
}
