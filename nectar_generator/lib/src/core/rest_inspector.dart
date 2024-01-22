import 'package:analyzer/dart/constant/value.dart';
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

  String _convertMapToStringMap(Map<DartObject?, DartObject?>? originalMap) {
    String convertedMap = "";
    if (originalMap != null) {
      originalMap.forEach((key, value) {
        if (key != null && value != null) {
          convertedMap +=
              "'${key.toStringValue()!}' : '${value.toStringValue()!}',";
        }
      });
    }
    return convertedMap;
  }

  String _addMiddlewaresIfNeed(MethodElement element, ElementAnnotation ann) {
    //TODO fix it if we will add new auth method!
    final jwtAuth = getAuthWithJwtAnnotation(element);
    final privilege = getHasPrivilegeAnnotation(element);
    final role = getHasRoleAnnotation(element);
    final headerAnn = getAddHeadersAnnotation(element);
    final contentType = getFieldNameFromRestAnnotation(ann, "contentType")
        ?.toStringValue()
        ?.toLowerCase();

    String? headersString;
    if (headerAnn != null) {
      final headers =
          getFieldNameFromRestAnnotation(headerAnn, "headers")?.toMapValue();
      headersString = _convertMapToStringMap(headers);
    }
    return ''' 
      use: setContentType('$contentType')
        ${headersString == null ? "" : ".addMiddleware(setHeadersMiddleware({$headersString}))"}
        ${(jwtAuth == null) ? "" : ".addMiddleware(checkJwtMiddleware())"}
        ${(jwtAuth == null || role == null) ? "" : ".addMiddleware(hasRoleMiddleware([${getFieldNameFromRestAnnotation(role, "value")!.toListValue()!.map((e) => "'${e.toStringValue()}'").join(",")}]))"}
        ${(jwtAuth == null || privilege == null) ? "" : ".addMiddleware(hasPrivilegeMiddleware([${getFieldNameFromRestAnnotation(privilege, "value")!.toListValue()!.map((e) => "'${e.toStringValue()}'").join(",")}]))"}
    ,''';
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
            ${_addMiddlewaresIfNeed(element, ann)}
         );
      ''';
  }

  String _buildParameterList(MethodElement e, bool applySymbol) => e
          .parameters.isEmpty
      ? ""
      : "${applySymbol ? " , " : ""} ${e.parameters.map((e) => e.name).join(',')}";

  MapEntry<String, String>? _parameterReader(int index, ParameterElement e) {
    var typeName =
        e.type.getDisplayString(withNullability: false).split("<").first;
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
      switch (typeName) {
        case 'int':
          return MapEntry("queryValue$index", ''' 
             var queryValue$index = int.tryParse(request.url.queryParameters["${fieldName ?? e.name}"] ?? "") ?? int.tryParse("'$defaultValue'");
           ''');
        case 'double':
          return MapEntry("queryValue$index", ''' 
             var queryValue$index = double.tryParse(request.url.queryParameters["${fieldName ?? e.name}"] ?? "") ?? double.tryParse("'$defaultValue'");
           ''');
        case 'bool':
          return MapEntry("queryValue$index", ''' 
             var queryValue$index = bool.tryParse(request.url.queryParameters["${fieldName ?? e.name}"] ?? "") ?? bool.tryParse("'$defaultValue'");
           ''');
        default:
          return MapEntry("queryValue$index", ''' 
             var queryValue$index = request.url.queryParameters["${fieldName ?? e.name}"];
             final defaultValue$index = ${defaultValue == null ? null : "'$defaultValue'"};
             if(defaultValue$index != null && queryValue$index == null){
                 queryValue$index = defaultValue$index;
             }
           ''');
      }

      return MapEntry("queryValue$index", ''' 
         var queryValue$index = request.url.queryParameters["${fieldName ?? e.name}"];
         final defaultValue$index = ${defaultValue == null ? null : "'$defaultValue'"};
         if(defaultValue$index != null && queryValue$index == null){
             queryValue$index = defaultValue$index;
         }
       ''');
    }
    pathVariable = getAnnotationFromParameter(e, "RequestBody");
    pathVariable ??= getFilesAnnotation(e);
    pathVariable ??= getFormDataAnnotation(e);
    pathVariable ??= getRawFormDataAnnotation(e);
    if (pathVariable != null) {
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
          final file = getFilesAnnotation(e);
          final form = getFormDataAnnotation(e);
          if (form != null) {
            return MapEntry("body$index", ''' 
              final body$index = <String, String>{};
              requestFormData.forEach((key, value) { 
                if(value is String){
                  body$index[key] = value;
                }
              });
              ''');
          }
          if (file != null) {
            return MapEntry("body$index", ''' 
              final body$index = <String, MultipartFile>{}; //Uint8List
              requestFormData.forEach((key, value) { 
                if(value is MultipartFile){
                  body$index[key] = value;
                }
              });
              ''');
          }
        default:
          return MapEntry("body$index", ''' 
            final str$index = await request.readAsString();
            final json$index = jsonDecode(str$index);
            final body$index = $typeName.fromJson(json$index);
          ''');
      }
    }
    switch (typeName) {
      case 'Request':
        return MapEntry("request$index", ''' 
            final request$index = request;
          ''');
      case 'UserDetails':
        return MapEntry("userDetails$index", ''' 
            final userDetails$index = request.context[MiddlewareKeys.userDetails]! as UserDetails;
          ''');
    }
    return null;
  }

  String _buildHandler(MethodElement e) {
    final acceptForm = getAcceptMultipartFormDataAnnotation(e) != null;
    final fields = e.parameters
        .mapIndexed(_parameterReader)
        .where((element) => element != null);
    return ''' 
      Future<dynamic> _${e.name}Handler(Request request) async {
         ${(acceptForm) ? ''' 
        if(!request.isMultipart || !request.isMultipartForm){
          throw RestException.badRequest(message: "request is not form");
        }
        final requestFormData = <String, dynamic>{
          await for (final formData in request.multipartFormData)
            if(formData.filename != null) formData.name: MultipartFile(name: formData.filename!, bytes: await formData.part.readBytes(),)
            else formData.name: await formData.part.readString(),
        };
        ''' : ""}
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
        } catch (e) {
          return Response(500, body: jsonEncode({"error": e.toString()}));
        }
      }
      
    }
 ''';
  }
}
