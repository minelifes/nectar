import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:nectar/nectar.dart';
import 'package:source_gen/source_gen.dart';

class NectarOrmGenerator extends GeneratorForAnnotation<Entity> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw 'The top @Entity() annotation can only be applied to classes.';
    }
  }
}
