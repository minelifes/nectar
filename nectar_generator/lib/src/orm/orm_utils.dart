import 'package:analyzer/dart/element/element.dart';

ElementAnnotation? getAnnotationFromField(FieldElement e, String name) =>
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

ElementAnnotation? getOrmAnnotation(FieldElement e) {
  var ann = getColumnAnnotation(e);
  if (ann != null) return ann;
  ann = getOneToOneAnnotation(e);
  if (ann != null) return ann;
  ann = getOneToManyAnnotation(e);
  if (ann != null) return ann;
  ann = getManyToOneAnnotation(e);
  if (ann != null) return ann;
  ann = getIdAnnotation(e);
  return ann;
}

String getFieldNameFromOrmAnnotation(FieldElement e) {
  final annotation = getOrmAnnotation(e);
  final obj = annotation?.computeConstantValue();
  return obj?.getField("name")?.toStringValue() ?? e.name;
}
