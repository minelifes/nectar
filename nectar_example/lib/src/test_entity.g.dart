// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entity.dart';

// **************************************************************************
// NectarOrmGenerator
// **************************************************************************

class Test extends _Test implements Model {
  Test();

  Map<String, dynamic> toJson() => {"id": id, "test_string": testString};

  factory Test.fromJson(Map<String, dynamic> json) => Test()
    ..id = json["id"]
    ..testString = json["test_string"];

  @override
  List<String> get columns => ["id", "test_string"];

  @override
  String get tableName => "test";

  @override
  void fromRow(Map result) {
    id = result["id"];
    testString = result["test_string"];
  }

  static TestQuery query() => TestQuery();

  Future<Test?> save() async => TestInsertClause(this, () => Test()).insert();

  Future<Test?> update() async => TestInsertClause(this, () => Test()).update();
}

class TestQuery extends Query<Test> {
  TestQuery() : super("test");

  @override
  Test instanceOfT() => Test();

  @override
  TestSelectClause select({List<String>? fields}) {
    if (fields != null) {
      model.fields = fields.join(", ");
    }
    return TestSelectClause(model, instanceOfT);
  }
}

class TestSelectClause extends SelectClause<Test> {
  TestSelectClause(super.model, super.instanceOfT);

  @override
  TestWhereClause where() => TestWhereClause(model, instanceOfT);
}

class TestWhereClause extends WhereClause<Test> {
  TestWhereClause(super.model, super.instanceOfT);

  TestWhereClause id(String value, {operator = "="}) {
    model.where["id"] = [operator, value];
    return this;
  }

  TestWhereClause testString(String value, {operator = "="}) {
    model.where["test_string"] = [operator, value];
    return this;
  }

  TestWhereClause customField(String key, value, {operator = "="}) {
    model.where[key] = [operator, value];
    return this;
  }
}

class TestInsertClause extends InsertClause<Test> {
  TestInsertClause(super.model, super.instanceOfT);

  @override
  Map<String, dynamic> toInsert() => {
        "id": model.id,
        "test_string": model.testString,
      };
}
