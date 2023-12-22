import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'dart:mirrors';

import 'class_inspector.dart';

class Serializable {
  final ClassInspector inspector;
  const Serializable(this.inspector);

  String generate() {
    return '''
      Map<String, dynamic> toJson() => {
        ${inspector.fields.map((e) => _serializeFieldIfAllowed(e)).join(",\n")}
      };
      
      factory ${inspector.name}.fromJson(Map<String, dynamic> json) => 
        ${inspector.name}()${inspector.fields.map((e) => _deserializeFieldIfAllowed(e)).join("")};
    ''';
  }

  String _serializeFieldIfAllowed(FieldElement e) {
    final annotation = e.metadata
        .where((e) => e.element?.enclosingElement?.name == "SerializableField")
        .firstOrNull;
    final obj = annotation?.computeConstantValue();
    final serializeName = obj?.getField("name")?.toStringValue() ?? e.name;
    final canSerialize = obj?.getField("serialize")?.toBoolValue() ?? true;
    if (canSerialize) {
      return '"$serializeName": ${e.name}';
    }
    return "";
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
      return '..${e.name} = json["$serializeName"]';
    }
    return "";
  }
}
