import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:nectar/nectar.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';

import 'orm_utils.dart';

class OrmQuerySerializer {
  final ClassInspector inspector;
  OrmQuerySerializer(this.inspector);

  String? _fieldNameFromRow(FieldElement e) {
    final referenceClass =
        getFieldValueFromRelationAnnotation(e, "referenceClass");
    if (referenceClass == null) {
      return "${inspector.tableName}.${getFieldNameFromOrmAnnotation(e)} as ${inspector.tableName}_${getFieldNameFromOrmAnnotation(e)}";
    }
    return null;
  }

  // JoinModel(
  // tableName: tableName,
  // mappedBy: mappedBy,
  // foreignTableName: foreignTableName,
  // foreignKey: foreignKey,
  // fields: ["Role.id as Role_id", "Role.title as Role_title"],
  // )
  Map<String, JoinModel> _joins = {};

  Future<void> _relationFieldList(
    FieldElement e,
    bool isFirst,
    String tableName,
    String mappedBy,
    String foreignTableName,
    String foreignKey,
  ) async {
    final referenceClass =
        getFieldValueFromRelationAnnotation(e, "referenceClass");
    if (referenceClass == null) {
      if (isFirst == true) return;
      final rowName =
          "$foreignTableName.${getFieldNameFromOrmAnnotation(e)} as ${foreignTableName}_${getFieldNameFromOrmAnnotation(e)}";
      if (!_joins.containsKey(foreignTableName)) {
        _joins[foreignTableName] = JoinModel(
          tableName: tableName,
          mappedBy: mappedBy,
          foreignTableName: foreignTableName,
          foreignKey: foreignKey,
          fields: [],
        );
      }
      _joins[foreignTableName]!.fields.add(rowName);
      return;
    }

    final _mappedBy = getFieldValueFromRelationAnnotation(e, "mappedBy");
    final _foreignKey = getFieldValueFromRelationAnnotation(e, "foreignKey");

    final clazz = await getClassInfo(inspector, referenceClass);
    if (clazz == null) return;
    final entity = getAnnotationFromClass(clazz, "Entity");
    if (entity == null) return;
    final _foreignTableName =
        entity.computeConstantValue()!.getField("tableName")!.toStringValue()!;
    await Future.wait(clazz.fields.map((e) async => await _relationFieldList(
          e,
          false,
          isFirst ? tableName : _foreignTableName,
          _mappedBy!,
          _foreignTableName,
          _foreignKey!,
        )));
  }

  String _getPrimaryKeyName() =>
      inspector.fields
          .where((e) => getIdAnnotation(e) != null)
          .firstOrNull
          ?.name ??
      "";

  Future<String> generate() async {
    (await Future.wait(inspector.fields.map((e) async =>
        await _relationFieldList(e, true, inspector.tableName, "", "", ""))));
    final joins = _joins.values.map((value) =>
        "JoinModel(tableName: '${value.tableName}', mappedBy: '${value.mappedBy}', foreignTableName: '${value.foreignTableName}', foreignKey: '${value.foreignKey}', fields: [${value.fields.map((e) => e.wrapWith()).join(', ')}],)");
    return '''
      class ${inspector.name}Query extends Query<${inspector.name}> {
        ${inspector.name}Query() : super("${inspector.tableName}", "${_getPrimaryKeyName()}");
      
        @override
        ${inspector.name} instanceOfT() => ${inspector.name}();
        
        List<String> get _defaultTableFields => [${inspector.fields.map(_fieldNameFromRow).where((element) => element != null).map((e) => e!.wrapWith()).join(', ')}];
        
        @override
        ${inspector.name}SelectClause select({List<String> fields = const [],}){
          model.fields = (fields.isEmpty) ? _defaultTableFields : fields;
          model.joins = [${joins.join(",")}];
          return ${inspector.name}SelectClause(model, instanceOfT);
        }
      }
    ''';
  }
}
