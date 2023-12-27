import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';

ElementAnnotation? getAnnotationFromMethod(MethodElement e, String name) =>
    e.metadata
        .where((e) => e.element?.enclosingElement?.name == name)
        .firstOrNull;

ElementAnnotation? getAnnotationFromParameter(
        ParameterElement e, String name) =>
    e.metadata
        .where((e) => e.element?.enclosingElement?.name == name)
        .firstOrNull;

ElementAnnotation? getGetMappingAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "GetMapping");

ElementAnnotation? getPostMappingAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "PostMapping");

ElementAnnotation? getPutMappingAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "PutMapping");

ElementAnnotation? getDeleteMappingAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "DeleteMapping");

ElementAnnotation? getPatchMappingAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "PatchMapping");

ElementAnnotation? getMappingAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "Mapping");

ElementAnnotation? getRequiredRoleAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "RequiredRole");

ElementAnnotation? getHasRoleAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "HasRole");

ElementAnnotation? getHasPrivilegeAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "HasPrivilege");

ElementAnnotation? getAuthWithJwtAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "AuthWithJwt");

bool hasOneOfMappingAnnotation(MethodElement e) =>
    (getGetMappingAnnotation(e) ??
        getPostMappingAnnotation(e) ??
        getPutMappingAnnotation(e) ??
        getPatchMappingAnnotation(e) ??
        getMappingAnnotation(e) ??
        getDeleteMappingAnnotation(e)) !=
    null;

DartObject? getFieldNameFromRestAnnotation(
    ElementAnnotation annotation, String fieldName) {
  final obj = annotation.computeConstantValue();
  return obj?.getField(fieldName);
}
