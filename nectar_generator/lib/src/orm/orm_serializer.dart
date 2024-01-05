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
      final isBool =
          e.type.getDisplayString(withNullability: false).toLowerCase() ==
              "bool";
      final className = e.type.getDisplayString(withNullability: false);
      if (isBool) {
        return '''
        if(result.containsKey('${inspector.tableName}')){
          final w${e.name} = ${(isEnum) ? "$className.values.firstWhere((e) => e.name == " : ""} result['${inspector.tableName}']['${inspector.tableName}_${getFieldNameFromOrmAnnotation(e)}'] ${(isEnum) ? ")" : ""};
          ${e.name} = (w${e.name} == 1) ? true : false;
        }else{
          final w${e.name} = ${(isEnum) ? "$className.values.firstWhere((e) => e.name == " : ""} result['${inspector.tableName}_${getFieldNameFromOrmAnnotation(e)}']  ${(isEnum) ? ")" : ""};
          ${e.name} = (w${e.name} == 1) ? true : false;
        }
      ''';
      }

      return '''
        if(result.containsKey('${inspector.tableName}')){
          ${e.name} = ${(isEnum) ? "$className.values.firstWhere((e) => e.name == " : ""} result['${inspector.tableName}']['${inspector.tableName}_${getFieldNameFromOrmAnnotation(e)}'] ${(isEnum) ? ")" : ""};
        }else{
          ${e.name} = ${(isEnum) ? "$className.values.firstWhere((e) => e.name == " : ""} result['${inspector.tableName}_${getFieldNameFromOrmAnnotation(e)}']  ${(isEnum) ? ")" : ""};
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
      final l_${e.name} = (result["$foreignTableName"] as List?);
      ${e.name} = (l_${e.name} == null || l_${e.name}.isEmpty == true) ? ${referenceClass.replaceFirst("_", "")}() : ${referenceClass.replaceFirst("_", "")}()..fromRow(l_${e.name}!.first);
    ''';
  }

  String _getPrimaryKeyName() =>
      inspector.fields
          .where((e) => getIdAnnotation(e) != null)
          .firstOrNull
          ?.name ??
      "";

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
            bool haveJoins = false,
            required String tableName,
          }) =>
              getIt
                  .get<Db>()
                  .query(sql, values: values, haveJoins: haveJoins, forTable: tableName,);
                  
       Future<int> delete() => getIt.get<Db>().delete(table: tableName, where: {primaryKeyName: ${_getPrimaryKeyName()}});
        
       static ${inspector.name}Migration migration() =>  ${inspector.name}Migration("${inspector.tableName}");
        
       static ${inspector.name}Query query() => ${inspector.name}Query();
       
       Future<${inspector.name}?> save() async => 
            await ${inspector.name}InsertClause(this,  () => ${inspector.name}()).insert();
          
    ''';
  }
}
