import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:nectar_generator/src/utils/string_utils.dart';
import 'package:source_gen/source_gen.dart';
import '../rest/rest_utils.dart';

class RestInspector {
  final ClassElement classElement;
  String name;

  late String mainPath;
  late String fileName;
  ClassElement? superClassElement;
  late FieldElement id;

  bool isTopClass = true;
  List<FieldElement> fields = [];
  List<MethodElement> methods = [];

  RestInspector(this.classElement, ConstantReader annotation)
      : name = classElement.name.removePrefix() {
    _setMainPath(annotation);

    fileName = classElement.source.shortName;
    fields = classElement.fields;
    methods = classElement.methods;
  }

  String generate() {
    return _buildClassWithColumns();
  }

  void _setMainPath(ConstantReader annotation) {
    if (annotation.read("path").isNull) return;
    mainPath = annotation.read("path").stringValue;
    if (mainPath.endsWith("/")) {
      mainPath = mainPath.substring(0, mainPath.length - 2);
    }
  }

  String _buildPath(String path) {
    if (path.startsWith("/")) return mainPath + path;
    return "$mainPath/$path";
  }

  String _addMiddlewaresIfNeed(MethodElement element) {
    //TODO fix it if we will add new auth method!
    final jwtAuth = getAuthWithJwtAnnotation(element);
    if (jwtAuth == null) return "";
    final privilege = getHasPrivilegeAnnotation(element);
    final role = getHasRoleAnnotation(element);
    return ''' 
      use: Pipeline()
            .addMiddleware(checkJwtMiddleware())
            ${(role == null) ? "" : ".addMiddleware(hasRoleMiddleware([${getFieldNameFromRestAnnotation(role, "value")!.toListValue()!.map((e) => "'${e.toStringValue()}'").join(",")}]))"}
            ${(privilege == null) ? "" : ".addMiddleware(hasPrivilegeMiddleware([${getFieldNameFromRestAnnotation(privilege, "value")!.toListValue()!.map((e) => "'${e.toStringValue()}'").join(",")}]))"}
            .middleware,
    ''';
  }

  String _buildRouteRegister(MethodElement element) {
    ElementAnnotation? ann = getGetMappingAnnotation(element);
    ann ??= getPostMappingAnnotation(element);
    ann ??= getPutMappingAnnotation(element);
    ann ??= getDeleteMappingAnnotation(element);
    ann ??= getPatchMappingAnnotation(element);
    ann ??= getMappingAnnotation(element);
    if (ann == null) return "\n";

    final path =
        getFieldNameFromRestAnnotation(ann, "path")?.toStringValue() ?? "/";
    final method = getFieldNameFromRestAnnotation(ann, "method")
        ?.toStringValue()
        ?.toLowerCase();

    if (method == null) {
      return "// can't generate code for '${element.name}' method: REST METHOD IS NULL \n\n";
    }
    return ''' 
         router.$method(
            "${_buildPath(path)}",
            controller._${element.name}Handler,
            ${_addMiddlewaresIfNeed(element)}
         );
      ''';
  }

  String _buildParameterList(MethodElement e, bool applySymbol) => e
          .parameters.isEmpty
      ? ""
      : "${applySymbol ? " , " : ""} ${e.parameters.map((e) => e.name).join(',')}";

  MapEntry<String, String>? _parameterReader(int index, ParameterElement e) {
    var pathVariable = getAnnotationFromParameter(e, "PathVariable");
    if (pathVariable != null) {
      final value = pathVariable.computeConstantValue();
      final fieldName = value?.getField("name")?.toStringValue();
      final defaultValue = value?.getField("defaultValue")?.toStringValue();
      var typeName = e.type.getDisplayString(withNullability: false);

      return MapEntry("pathValue$index", ''' 
         final defaultValue$index = ${defaultValue == null ? null : "'$defaultValue'"};
         $typeName pathValue$index = _convertPathVariableToType('$typeName', request.params["${fieldName ?? e.name}"], defaultValue$index);
       ''');
    }
    pathVariable = getAnnotationFromParameter(e, "QueryVariable");
    if (pathVariable != null) {
      final value = pathVariable.computeConstantValue();
      final fieldName = value?.getField("name")?.toStringValue();
      final defaultValue = value?.getField("defaultValue")?.toStringValue();
      return MapEntry("queryValue$index", ''' 
         var queryValue$index = request.url.queryParameters["${fieldName ?? e.name}"];
         final defaultValue$index = ${defaultValue == null ? null : "'$defaultValue'"};
         if(defaultValue$index != null && queryValue$index == null){
             queryValue$index = defaultValue$index;
         }
       ''');
    }
    pathVariable = getAnnotationFromParameter(e, "RequestBody");
    if (pathVariable != null) {
      var typeName = e.type.getDisplayString(withNullability: false);
      switch (typeName) {
        case 'String':
          return MapEntry("body$index", ''' 
            final  = await request.readAsString();
         ''');
        case 'int':
          return MapEntry("body$index", ''' 
            final str$index = await request.readAsString();
            final body$index = int.tryParse(str$index);
         ''');
        case 'double':
          return MapEntry("body$index", ''' 
            final str$index = await request.readAsString();
            final body$index = double.tryParse(str$index);
         ''');
        case 'bool':
          return MapEntry("body$index", ''' 
            final str$index = await request.readAsString();
            final body$index = bool.tryParse(str$index);
          ''');
        case 'Map':
          return MapEntry("body$index", ''' 
            final str$index = await request.readAsString();
            final body$index = jsonDecode(str$index);
          ''');
        default:
          return MapEntry("body$index", ''' 
            final str$index = await request.readAsString();
            final json$index = jsonDecode(str$index);
            final body$index = $typeName.fromJson(json$index);
          ''');
      }
    }
    return null;
  }

  String _buildHandler(MethodElement e) {
    final fields = e.parameters
        .mapIndexed(_parameterReader)
        .where((element) => element != null);
    return ''' 
      Future<dynamic> _${e.name}Handler(Request request) async {
        return await _returnResponseOrError(() async {
          ${fields.map((el) => el!.value).join("\n")}
          return await ${e.name}(${fields.map((el) => '${el!.key}').join(",")});
        });
      }
    ''';
  }

  String _buildClassWithColumns() {
    return '''
    class $name extends _$name {
    
      $name();
      
      static void register() {
        Routes.registerRoute((router) {
          final controller = $name();
          ${methods.map(_buildRouteRegister).join("\n\n")}
        });
      }
   
      ${methods.map((e) => _buildHandler(e)).join("\n\n")}
      
        dynamic _convertPathVariableToType(String type, String? path, String? defaultValue) {
          if(path == null && defaultValue == null) return null;
          switch (type) {
            case 'String':
              return path ?? defaultValue ?? "";
            case 'int':
              return int.tryParse(path ?? defaultValue ?? "");
            case 'double':
              return double.tryParse(path ?? defaultValue ?? "");
            case 'bool':
              return bool.tryParse(path ?? defaultValue ?? "");
          }
        }
      
      Future<dynamic> _returnResponseOrError(
        Future<dynamic> Function() call,
      ) async {
        try {
          return await call();
        } on RestException catch (e) {
          return Response(e.statusCode, body: jsonEncode({"error": e.toString()}));
        } on Exception catch (e) {
          return Response(500, body: jsonEncode({"error": e.toString()}));
        }
      }
      
    }
 ''';
  }
}
