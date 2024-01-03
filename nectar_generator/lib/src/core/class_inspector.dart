import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:nectar_generator/src/orm/orm_insert_serializer.dart';
import 'package:nectar_generator/src/orm/orm_migration_serializer.dart';
import 'package:nectar_generator/src/orm/orm_query_serializer.dart';
import 'package:nectar_generator/src/orm/orm_select_serializer.dart';
import 'package:nectar_generator/src/orm/orm_serializer.dart';
import 'package:nectar_generator/src/orm/orm_where_serializer.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';
import 'package:source_gen/source_gen.dart';

import '../serializable/serializable.dart';

class ClassInspector {
  final ClassElement classElement;
  final BuildStep buildStep;
  String name;

  late String tableName;
  late String fileName;
  ClassElement? superClassElement;
  late FieldElement id;

  bool isTopClass = true;
  List<FieldElement> fields = [];
  List<MethodElement> methods = [];

  ClassInspector(this.classElement, this.buildStep, ConstantReader annotation)
      : name = classElement.name.removePrefix() {
    _setTableName(annotation);

    fileName = classElement.source.shortName;
    fields = classElement.fields;
    methods = classElement.methods;
  }

  Future<String> generate() async {
    final s = Serializable(this);
    final orm = OrmSerializer(this);
    final q = OrmQuerySerializer(this);
    final os = OrmSelectSerializer(this);
    final w = OrmWhereSerializer(this);
    final ins = OrmInsertSerializer(this);
    final mig = OrmMigrationSerializer(this);
    return _buildClassWithColumns([
      s.generate(),
      await orm.generate(),
    ], [
      await q.generate(),
      os.generate(),
      await w.generate(),
      await ins.generate(),
      await mig.generate(),
    ]);
  }

  void _setTableName(ConstantReader annotation) {
    if (annotation.read("tableName").isNull) {
      tableName = name.toLowerCase();
      return;
    }
    tableName = annotation.read("tableName").stringValue;
  }

  String _buildClassWithColumns(
      List<String> codeInside, List<String> codeAfter) {
    return '''
    class $name extends _$name implements Model {
    
      $name();
      
      ${codeInside.join("\n\n")}
      
    }
    
    ${codeAfter.join("\n\n")}
    ''';
  }
}
