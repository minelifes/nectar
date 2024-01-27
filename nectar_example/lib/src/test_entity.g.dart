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

  _valueForList(e) {
    if (e is String ||
        e is num ||
        e is bool ||
        e is int ||
        e is double ||
        e is Enum ||
        e is Map) {
      return e;
    }
    if (e is List || e is Set) {
      return _valueForList(e);
    }
    return e.toJson();
  }

  @override
  List<String> get columns => ["id", "test_string"];

  @override
  String get tableName => "test";

  @override
  void fromRow(Map result) {
    if (result.containsKey('test')) {
      id = result['test']['id'];
    } else {
      // if(result.containsKey('id') == true)
      id = result['id'];
    }

    if (result.containsKey('test')) {
      testString = result['test']['test_string'];
    } else {
      // if(result.containsKey('test_string') == true)
      testString = result['test_string'];
    }
  }

  @override
  String get primaryKeyName => "id";

  static Future<ResultFormat> rawQuery(
    String sql, {
    Map<String, dynamic> values = const {},
    List<JoinModel> joins = const [],
    required String tableName,
  }) =>
      getIt.get<Db>().query(
            sql,
            values: values,
            joins: joins,
            forTable: tableName,
          );

  Future<int> delete() =>
      getIt.get<Db>().delete(table: tableName, where: {primaryKeyName: id});

  static TestMigration migration() => TestMigration("test");

  static TestQuery query() => TestQuery();

  Future<Test?> save() async =>
      await TestInsertClause(this, () => Test()).insert();
}

class TestQuery extends Query<Test> {
  TestQuery() : super("test", "id");

  @override
  Test instanceOfT() => Test();

  List<String> get _defaultTableFields =>
      ["test.id as test\$id", "test.test_string as test\$test_string"];

  @override
  TestSelectClause select({
    List<String> fields = const [],
  }) {
    model.fields = (fields.isEmpty) ? _defaultTableFields : fields;
    model.joins = [];
    return TestSelectClause(model, instanceOfT);
  }
}

class TestSelectClause extends SelectClause<Test> {
  TestSelectClause(super.model, super.instanceOfT);

  @override
  TestWhereClause where() => TestWhereClause(model, instanceOfT);

  @override
  TestSelectClause join(JoinModel join) {
    model.joins.add(join);
    return this;
  }
}

class TestWhereClause extends WhereClause<Test> {
  TestWhereClause(super.model, super.instanceOfT);

  TestWhereClause id(String? value, {operator = "="}) {
    model.where["test.id"] = [operator, value];
    return this;
  }

  TestWhereClause testString(String value, {operator = "="}) {
    model.where["test.test_string"] = [operator, value];
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
  Future<Test?> selectOne(String primaryKeyName, dynamic value) async =>
      (await TestQuery()
              .select()
              .where()
              .addCustom('test.$primaryKeyName', value)
              .list())
          .firstOrNull;

  @override
  Map<String, dynamic> toInsert() => {
        "id": model.id,
        "test_string": model.testString,
      };
}

class TestMigration extends Migration {
  TestMigration(super.tableName);

  @override
  List<ColumnInfo> get columns => [
        ColumnInfo(
          name: 'id',
          columnType: ColumnType.varchar,
          defaultValue: null,
          isKey: true,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'test_string',
          columnType: ColumnType.text,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        )
      ];
}
