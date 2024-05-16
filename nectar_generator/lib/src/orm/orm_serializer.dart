import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
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
      final isEnum = getEnumColumnAnnotation(e) != null;
      final isDate = e.type.toString() == "DateTime";
      final isBool =
          e.type.getDisplayString(withNullability: false).toLowerCase() ==
              "bool";
      final className = e.type.getDisplayString(withNullability: false);
      if (isBool) {
        return '''
        if(result.containsKey('${inspector.tableName}')){
          final w${e.name} = result['${inspector.tableName}']['${getFieldNameFromOrmAnnotation(e)}'];
          ${e.name} = (w${e.name} == 1) ? true : false;
        } else { 
          final w${e.name} = result['${getFieldNameFromOrmAnnotation(e)}'];
          ${e.name} = (w${e.name} == 1) ? true : false;
        }
      ''';
      }

      if (isDate) {
        return '''
        if(result.containsKey('${inspector.tableName}')){
          final w${e.name} = result['${inspector.tableName}']['${getFieldNameFromOrmAnnotation(e)}'];
          ${e.name} = DateTime.parse(w${e.name});
        } else { 
          final w${e.name} = result['${getFieldNameFromOrmAnnotation(e)}'];
          ${e.name} = DateTime.parse(w${e.name});
        }
      ''';
      }

      return '''
        if(result.containsKey('${inspector.tableName}')){
          ${e.name} = ${(isEnum) ? "$className.values.firstWhere((e) => e.name == " : ""} result['${inspector.tableName}']['${getFieldNameFromOrmAnnotation(e)}'] ${(isEnum) ? ")" : ""};
        } else {
          ${e.name} = ${(isEnum) ? "$className.values.firstWhere((e) => e.name == " : ""} result['${getFieldNameFromOrmAnnotation(e)}']  ${(isEnum) ? ")" : ""};
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
        ${e.name} = ((result["$foreignTableName"] as Map<dynamic, dynamic>?))?.values.map((e) => $className()..fromRow(e)).toList() ?? [];
      ''';
    }
    return '''
      final l_${e.name} = (result["$foreignTableName"] as Map<dynamic, dynamic>?);
      ${e.name} = (l_${e.name} == null || l_${e.name}.isNotEmpty != true)
          ? ${getRawFieldValueFromOrmAnnotation(e, "nullable")?.toBoolValue() == true ? "null" : "${referenceClass.replaceFirst("_", "")}()"}
          : (${referenceClass.replaceFirst("_", "")}()..fromRow(l_${e.name}.values.first));
    ''';
  }

  String _getPrimaryKeyName() {
      final field = inspector.fields
          .where((e) => getIdAnnotation(e) != null)
          .firstOrNull;
      if(field == null) return "";
      final idAnn = getIdAnnotation(field)!;
      final name = getFieldFromAnnotation(idAnn, "name");
      return name?.toStringValue() ?? field.name;
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
        
        @override
        String get primaryKeyName => "${_getPrimaryKeyName()}";
        
        static Future<ResultFormat> rawQuery(
            String sql, {
            Map<String, dynamic> values = const {},
            List<JoinModel> joins = const [],
            required String tableName,
          }) =>
              getIt
                  .get<Db>()
                  .query(sql, values: values, joins: joins, forTable: tableName,);
                  
       Future<int> delete() => getIt.get<Db>().delete(table: tableName, where: {primaryKeyName: ${_getPrimaryKeyName()}});
        
       static ${inspector.name}Migration migration() =>  ${inspector.name}Migration("${inspector.tableName}");
        
       static ${inspector.name}Query query() => ${inspector.name}Query();
       
       Future<${inspector.name}?> save() async => 
            await ${inspector.name}InsertClause(this,  () => ${inspector.name}()).insert();
          
    ''';
  }
}
