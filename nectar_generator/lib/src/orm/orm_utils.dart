import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:nectar_generator/src/core/class_inspector.dart';
import 'package:source_gen/source_gen.dart';

ElementAnnotation? getAnnotationFromField(FieldElement e, String name) =>
    e.metadata
        .where((e) => e.element?.enclosingElement?.name == name)
        .firstOrNull;

ElementAnnotation? getAnnotationFromClass(ClassElement e, String name) =>
    e.metadata
        .where((e) => e.element?.enclosingElement?.name == name)
        .firstOrNull;

ElementAnnotation? getColumnAnnotation(FieldElement e) =>
    getAnnotationFromField(e, "Column");

ElementAnnotation? getOneToOneAnnotation(FieldElement e) =>
    getAnnotationFromField(e, "OneToOne");

ElementAnnotation? getOneToManyAnnotation(FieldElement e) =>
    getAnnotationFromField(e, "OneToMany");

ElementAnnotation? getManyToOneAnnotation(FieldElement e) =>
    getAnnotationFromField(e, "ManyToOne");

ElementAnnotation? getIdAnnotation(FieldElement e) =>
    getAnnotationFromField(e, "Id");

ElementAnnotation? getUUIdAnnotation(FieldElement e) =>
    getAnnotationFromField(e, "UuidGenerate");

ElementAnnotation? getAutoIncrementAnnotation(FieldElement e) =>
    getAnnotationFromField(e, "AutoIncrement");

ElementAnnotation? getEnumColumnAnnotation(FieldElement e) =>
    getAnnotationFromField(e, "EnumColumn");

ElementAnnotation? getOrmAnnotation(FieldElement e) {
  var ann = getColumnAnnotation(e);
  if (ann != null) return ann;
  ann = getEnumColumnAnnotation(e);
  if (ann != null) return ann;
  ann = getRelationAnnotation(e);
  if (ann != null) return ann;
  ann = getIdAnnotation(e);
  return ann;
}

ElementAnnotation? getRelationAnnotation(FieldElement e) {
  var ann = getOneToOneAnnotation(e);
  if (ann != null) return ann;
  ann = getOneToManyAnnotation(e);
  if (ann != null) return ann;
  ann = getManyToOneAnnotation(e);
  return ann;
}

String getFieldNameFromOrmAnnotation(FieldElement e) =>
    getFieldValueFromOrmAnnotation(e, "name") ??
    getFieldValueFromOrmAnnotation(e, "mappedBy") ??
    e.name;

DartObject? getFieldFromAnnotation(ElementAnnotation? annotation, String name) {
  final obj = annotation?.computeConstantValue();
  return obj?.getField(name);
}

DartObject? getFieldValueFromColumn(FieldElement e, String name) {
  final annotation = getColumnAnnotation(e);
  final obj = annotation?.computeConstantValue();
  return obj?.getField(name);
}

String? getFieldValueFromOrmAnnotation(FieldElement e, String name) {
  final annotation = getOrmAnnotation(e);
  final obj = annotation?.computeConstantValue();
  return obj?.getField(name)?.toStringValue();
}

DartObject? getRawFieldValueFromOrmAnnotation(FieldElement e, String name) {
  final annotation = getOrmAnnotation(e);
  final obj = annotation?.computeConstantValue();
  return obj?.getField(name);
}

String? getFieldValueFromRelationAnnotation(FieldElement e, String name) {
  final annotation = getRelationAnnotation(e);
  final obj = annotation?.computeConstantValue();
  return obj?.getField(name)?.toStringValue();
}

Future<ClassElement?> getClassInfo(
    ClassInspector inspector, String className) async {
  final libraries = await inspector.buildStep.resolver.libraries.toList();
  for (var lib in libraries) {
    final libraryReader = LibraryReader(lib);
    final clazz =
        libraryReader.classes.singleWhereOrNull((c) => c.name == className);
    if (clazz != null) return clazz;
  }
  return null;
}
