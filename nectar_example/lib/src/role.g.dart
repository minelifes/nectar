// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// NectarOrmGenerator
// **************************************************************************

class Role extends _Role implements Model {
  Role();

  Map<String, dynamic> toJson() => {"key": key, "name": name};

  factory Role.fromJson(Map<String, dynamic> json) => Role()
    ..key = json["key"]
    ..name = json["name"];

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
  List<String> get columns => ["key", "name"];

  @override
  String get tableName => "roles";

  @override
  void fromRow(Map result, Map? allResponse) {
    if (result.containsKey('roles')) {
      key = result['roles']['roles_key'];
    } else if (result.containsKey('roles_key') == true) {
      key = result['roles_key'];
    } else if (allResponse?.containsKey('roles_key') == true) {
      key = allResponse!['roles_key'];
    } else {
      key = allResponse!['roles'].first['roles_key'];
    }

    if (result.containsKey('roles')) {
      name = result['roles']['roles_name'];
    } else if (result.containsKey('roles_name') == true) {
      name = result['roles_name'];
    } else if (allResponse?.containsKey('roles_name') == true) {
      name = allResponse!['roles_name'];
    } else {
      name = allResponse!['roles'].first['roles_name'];
    }
  }

  @override
  String get primaryKeyName => "key";

  static Future<ResultFormat> rawQuery(
    String sql, {
    Map<String, dynamic> values = const {},
    bool haveJoins = false,
    required String tableName,
  }) =>
      getIt.get<Db>().query(
            sql,
            values: values,
            haveJoins: haveJoins,
            forTable: tableName,
          );

  Future<int> delete() =>
      getIt.get<Db>().delete(table: tableName, where: {primaryKeyName: key});

  static RoleMigration migration() => RoleMigration("roles");

  static RoleQuery query() => RoleQuery();

  Future<Role?> save() async =>
      await RoleInsertClause(this, () => Role()).insert();
}

class RoleQuery extends Query<Role> {
  RoleQuery() : super("roles", "key");

  @override
  Role instanceOfT() => Role();

  List<String> get _defaultTableFields =>
      ["roles.key as roles_key", "roles.name as roles_name"];

  @override
  RoleSelectClause select({
    List<String> fields = const [],
  }) {
    model.fields = (fields.isEmpty) ? _defaultTableFields : fields;
    model.joins = [];
    return RoleSelectClause(model, instanceOfT);
  }
}

class RoleSelectClause extends SelectClause<Role> {
  RoleSelectClause(super.model, super.instanceOfT);

  @override
  RoleWhereClause where() => RoleWhereClause(model, instanceOfT);

  @override
  RoleSelectClause join(JoinModel join) {
    model.joins.add(join);
    return this;
  }
}

class RoleWhereClause extends WhereClause<Role> {
  RoleWhereClause(super.model, super.instanceOfT);

  RoleWhereClause key(String? value, {operator = "="}) {
    model.where["roles.key"] = [operator, value];
    return this;
  }

  RoleWhereClause name(String value, {operator = "="}) {
    model.where["roles.name"] = [operator, value];
    return this;
  }

  RoleWhereClause customField(String key, value, {operator = "="}) {
    model.where[key] = [operator, value];
    return this;
  }
}

class RoleInsertClause extends InsertClause<Role> {
  RoleInsertClause(super.model, super.instanceOfT);

  @override
  Future<Role?> selectOne(String primaryKeyName, dynamic value) => RoleQuery()
      .select()
      .where()
      .addCustom('roles.$primaryKeyName', value)
      .one();

  @override
  Map<String, dynamic> toInsert() => {
        "key": model.key,
        "name": model.name,
      };
}

class RoleMigration extends Migration {
  RoleMigration(super.tableName);

  @override
  List<ColumnInfo> get columns => [
        ColumnInfo(
          name: 'key',
          columnType: ColumnType.varchar,
          defaultValue: null,
          isKey: true,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'name',
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
