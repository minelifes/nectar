import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:nectar/nectar.dart';
import 'package:source_gen/source_gen.dart';

import 'core/class_inspector.dart';

class NectarOrmGenerator extends GeneratorForAnnotation<Entity> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw 'The top @Entity() annotation can only be applied to classes.';
    }

    final classInspector = ClassInspector(element, annotation).generate();
    print(classInspector);
    return classInspector;
  }
}
