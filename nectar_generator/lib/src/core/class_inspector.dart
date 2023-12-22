import 'package:analyzer/dart/element/element.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';
import 'package:source_gen/source_gen.dart';

import 'serializable.dart';

class ClassInspector {
  final ClassElement classElement;
  String name;

  late String tableName;
  late String fileName;
  ClassElement? superClassElement;
  late FieldElement id;

  bool isTopClass = true;
  List<FieldElement> fields = [];
  List<MethodElement> methods = [];

  ClassInspector(this.classElement, ConstantReader annotation)
      : name = classElement.name.removePrefix() {
    _setTableName(annotation);

    this.fileName = classElement.source.shortName;
    this.fields = classElement.fields;
    this.methods = classElement.methods;

    tableName = name.toLowerCase();
  }

  String generate() {
    final s = Serializable(this);
    return _buildClassWithColumns([s.generate()]);
    // return [_buildClassWithColumns()].join("\n\n");
  }

  void _setTableName(ConstantReader annotation) {
    if (annotation.read("tableName").isNull) {
      tableName = name.toLowerCase();
      return;
    }
    tableName = annotation.read("tableName").stringValue;
  }

  String _buildClassWithColumns(List<String> codeInside) {
    // fields.map((e) => print(
    //     "e.type.getDisplayString(withNullability: true): ${e.type.getDisplayString(withNullability: true)}"));
    // ${fields.map((e) => "${e.type.getDisplayString(withNullability: true)} get ${e.name} => _${e.name};\n")}
    return '''
    class $name extends _$name {
    
      $name();
      
      ${codeInside.join("\n\n")}
      
    }
    ''';
  }
}
