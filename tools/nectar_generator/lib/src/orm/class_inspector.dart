import 'package:analyzer/dart/element/element.dart';
import 'package:nectar/nectar.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';
import 'package:source_gen/source_gen.dart';

class ClassInspector {
  final ClassElement classElement;
  String name;

  late String tableName;
  ClassElement? superClassElement;
  late Entity entity;

  bool isTopClass = true;
  List<FieldElement> fields = [];
  List<MethodElement> methods = [];

  ClassInspector(this.classElement, ConstantReader annotation)
      : name = classElement.name.removePrefix() {
    print(annotation.read("tableName"));
    // handleAnnotations(this.classElement);
    //
    // this.entity = this.ormAnnotations.whereType<Entity>().first;

    this.fields = classElement.fields;
    this.methods = classElement.methods;

    // this.classElement

    tableName = name.toLowerCase();
  }
}
