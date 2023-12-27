import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'dart:mirrors';

import '../core/class_inspector.dart';

class Serializable {
  final ClassInspector inspector;
  Serializable(this.inspector);

  String generate() {
    return '''
      Map<String, dynamic> toJson() => {
        ${inspector.fields.map((e) => _serializeFieldIfAllowed(e)).join(",\n")}
      };
      
      factory ${inspector.name}.fromJson(Map<String, dynamic> json) => 
        ${inspector.name}()${inspector.fields.map((e) => _deserializeFieldIfAllowed(e)).join("")};
        
      _valueForList(e){
        if(e is String || e is num || e is bool || e is int || e is double || e is Enum || e is Map){
          return e;
        }
        if(e is List){
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
    if (canSerialize) {
      if (_isFieldEasyType(e)) {
        return '"$serializeName": ${e.name}';
      } else if (_isFieldDate(e)) {
        return '"$serializeName": ${e.name}.toIso8601String()';
      } else if (_isList(e)) {
        return '"$serializeName": ${e.name}.map(_valueForList).toList()';
      } else {
        return '"$serializeName": ${e.name}.toJson()';
      }
    }
    return "";
  }

  final _allowedTypes = [
    "int",
    "double",
    "String",
    "bool",
    "Map",
    "Enum",
  ];

  bool _isFieldDate(FieldElement field) {
    final type = field.type.getDisplayString(withNullability: false);
    return type == "DateTime";
  }

  bool _isList(FieldElement field) {
    final type = field.type.getDisplayString(withNullability: false);
    return type == "List";
  }

  bool _isFieldEasyType(FieldElement field) {
    final type = field.type.getDisplayString(withNullability: false);
    return _allowedTypes.contains(type);
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
