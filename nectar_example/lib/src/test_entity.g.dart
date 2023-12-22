// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entity.dart';

// **************************************************************************
// NectarOrmGenerator
// **************************************************************************

class Test extends _Test {
  Test();

  Map<String, dynamic> toJson() => {"id": id, "test_string": testString};

  factory Test.fromJson(Map<String, dynamic> json) => Test()
    ..id = json["id"]
    ..testString = json["test_string"];
}
