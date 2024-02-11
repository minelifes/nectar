import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:nectar_generator/src/orm/orm_utils.dart';

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

ElementAnnotation? getAddHeadersAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "AddHeaders");

ElementAnnotation? getHasPrivilegeAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "HasPrivilege");

ElementAnnotation? getAuthWithJwtAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "AuthWithJwt");

ElementAnnotation? getAcceptMultipartFormDataAnnotation(MethodElement e) =>
    getAnnotationFromMethod(e, "AcceptMultipartFormData");

ElementAnnotation? getRawFormDataAnnotation(ParameterElement e) =>
    getAnnotationFromParameter(e, "RawFormData");

ElementAnnotation? getFilesAnnotation(ParameterElement e) =>
    getAnnotationFromParameter(e, "Files");

ElementAnnotation? getFormDataAnnotation(ParameterElement e) =>
    getAnnotationFromParameter(e, "MapFormData");

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

final _allowedTypes = [
  "int",
  "double",
  "String",
  "bool",
  "Map",
  "Enum",
];

bool isFieldDate(FieldElement field) {
  final type = field.type.getDisplayString(withNullability: false);
  return type == "DateTime";
}

bool isFieldList(FieldElement field) {
  final type = field.type.getDisplayString(withNullability: false);
  final typeName = type.split("<").firstOrNull;
  return typeName == "List" || typeName == "Set";
}

bool isFieldEasyType(FieldElement field) {
  final type = field.type.getDisplayString(withNullability: false);
  // final isEnum = getEnumColumnAnnotation(field) != null;
  return _allowedTypes.contains(type);
}

bool isFieldEnumType(FieldElement field) {
  final isEnum = getEnumColumnAnnotation(field) != null;
  return isEnum;
}

String serializeField(String key, FieldElement e, {bool nullable = false}) {
  if (isFieldEasyType(e)) {
    return '"$key": ${e.name}';
  } else if (isFieldEnumType(e)) {
    return '"$key": ${e.name}${nullable ? "?" : ""}.name';
  } else if (isFieldDate(e)) {
    return '"$key": ${e.name}${nullable ? "?" : ""}.toIso8601String()';
  } else if (isFieldList(e)) {
    return '"$key": ${e.name}${nullable ? "?" : ""}.map(_valueForList).toList()';
  } else {
    return '"$key": ${e.name}${nullable ? "?" : ""}.toJson()';
  }
}

String deserealizeField(String serializeName, FieldElement e) {
  if (isFieldEasyType(e)) {
    return '..${e.name} = json["$serializeName"]';
  } else if (isFieldEnumType(e)) {
    return '..${e.name} = ${e.type.getDisplayString(withNullability: false)}.values.firstWhere((element) => element.name == json["$serializeName"])';
  } else if (isFieldDate(e)) {
    return '..${e.name} = DateTime.tryParse(json["$serializeName"]) ?? DateTime.fromMicrosecondsSinceEpoch(0, isUtc: false)'; //'"$key": ${e.name}?.toIso8601String()';
  } else if (isFieldList(e)) {
    final referenceClass = getFieldValueFromOrmAnnotation(e, "referenceClass")
        ?.replaceFirst("_", "");
    if (referenceClass?.isNotEmpty != true) return "";
    return '..${e.name} = (json["$serializeName"] as List<dynamic>).map((e)=> $referenceClass.fromJson(e)).toList()';
  } else {
    final referenceClass = getFieldValueFromOrmAnnotation(e, "referenceClass")
        ?.replaceFirst("_", "");
    if (referenceClass?.isNotEmpty != true) return "";
    return '..${e.name} = $referenceClass.fromJson(json["$serializeName"])';
  }
}
