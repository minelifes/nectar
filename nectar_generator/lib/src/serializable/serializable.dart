import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:nectar_generator/src/orm/orm_utils.dart';
import 'package:nectar_generator/src/rest/rest_utils.dart';
import 'dart:mirrors';

import '../core/class_inspector.dart';

class Serializable {
  final ClassInspector inspector;
  Serializable(this.inspector);

  String? customToJsonMethod(){
    for (var value in inspector.methods) {
      for (var value1 in value.metadata) {
        final name = value1.element?.displayName;
        if(name == "ToJson") {
          return value.displayName;
        }
      }
    }
    return null;
  }

  String generate() {
    final toJson = customToJsonMethod();
    String str = "";
    if(toJson != null){
      str = """
        Map<String, dynamic> toJson() => $toJson();
      """;
    } else {
      str = """
      Map<String, dynamic> toJson() => {
        ${inspector.fields.map((e) => _serializeFieldIfAllowed(e)).join(",\n")}
      };
      """;
    }

    return '''
      $str
      
      factory ${inspector.name}.fromJson(Map<String, dynamic> json) => 
        ${inspector.name}()${inspector.fields.map((e) => _deserializeFieldIfAllowed(e)).where((element) => element.isNotEmpty).join("\n")};
        
      _valueForList(e){
        if(e is String || e is num || e is bool || e is int || e is double || e is Enum || e is Map){
          return e;
        }
        if(e is List || e is Set){
          return _valueForList(e);
        }
        return e.toJson();
      }
        
    ''';
  }

  String _serializeFieldIfAllowed(FieldElement e) {
    final annotation = e.metadata
        .where((e) => e.element?.enclosingElement?.name == "SerializableField")
        .firstOrNull;
    final obj = annotation?.computeConstantValue();
    final serializeName = obj?.getField("name")?.toStringValue() ?? e.name;
    final canSerialize = obj?.getField("serialize")?.toBoolValue() ?? true;
    if (!canSerialize) return "";
    final ann = getColumnAnnotation(e) ??
        getOneToManyAnnotation(e) ??
        getOneToOneAnnotation(e) ??
        getManyToOneAnnotation(e);
    var nullable = false;
    if (ann != null) {
      nullable =
          getFieldNameFromRestAnnotation(ann, "nullable")?.toBoolValue() ??
              false;
    } else {
      final nullableAnn = obj?.getField("nullable")?.toBoolValue() ?? false;
      nullable = e.computeConstantValue()?.isNull ?? nullableAnn;
    }
    return serializeField(serializeName, e, nullable: nullable);
  }

  dynamic _getValueFromDartObject(DartObject? value) {
    if (value == null) return null;
    final fieldType = value.type?.getDisplayString(withNullability: false);
    if (fieldType == null) return null;
    switch (fieldType) {
      case 'int':
        return value.toIntValue();
      case 'double':
        return value.toDoubleValue();
      case 'float':
        return value.toDoubleValue();
      case 'String':
        return value.toStringValue();
      case 'bool':
        return value.toBoolValue();
      case 'List':
        return value
            .toListValue()
            ?.map((e) => _getValueFromDartObject(e))
            .toList();
      case 'Map':
        return value.toMapValue();
      default:
        final v = value.toTypeValue();
        final instanceMirror = reflect(v?.element?.thisOrAncestorOfType());
        final classMirror = instanceMirror.type;

        if (classMirror.declarations.containsKey(Symbol('toJson'))) {
          return instanceMirror.invoke(Symbol('toJson'), []).reflectee;
        } else {
          throw Exception('No toJson method found');
        }
    }
  }

  String _deserializeFieldIfAllowed(FieldElement e) {
    final annotation = e.metadata
        .where((e) => e.element?.enclosingElement?.name == "SerializableField")
        .firstOrNull;
    final obj = annotation?.computeConstantValue();
    final serializeName = obj?.getField("name")?.toStringValue() ?? e.name;
    final canDeserealize = obj?.getField("deserialize")?.toBoolValue() ?? true;
    if (canDeserealize) {
      return deserealizeField(serializeName, e);
      // return '..${e.name} = json["$serializeName"]';
    }
    return "";
  }
}
