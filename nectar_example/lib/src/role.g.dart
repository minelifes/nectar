// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// NectarOrmGenerator
// **************************************************************************

class Role extends _Role implements Model {
  Role();

  Map<String, dynamic> toJson() => {"id": id, "title": title};

  factory Role.fromJson(Map<String, dynamic> json) => Role()
    ..id = json["id"]
    ..title = json["title"];

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
  List<String> get columns => ["id", "title"];

  @override
  String get tableName => "Role";

  @override
  void fromRow(Map result) {
    if (result.containsKey('Role')) {
      id = result['Role']['Role_id'];
    } else {
      id = result['Role_id'];
    }

    if (result.containsKey('Role')) {
      title = result['Role']['Role_title'];
    } else {
      title = result['Role_title'];
    }
  }

  @override
  String get primaryKeyName => "id";

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

  static RoleMigration migration() => RoleMigration("Role");

  static RoleQuery query() => RoleQuery();

  Future<Role?> save() async =>
      await RoleInsertClause(this, () => Role()).insert();
}

class RoleQuery extends Query<Role> {
  RoleQuery() : super("Role", "id");

  @override
  Role instanceOfT() => Role();

  List<String> get _defaultTableFields =>
      ["Role.id as Role_id", "Role.title as Role_title"];

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

  RoleWhereClause id(String? value, {operator = "="}) {
    model.where["Role.id"] = [operator, value];
    return this;
  }

  RoleWhereClause title(String value, {operator = "="}) {
    model.where["Role.title"] = [operator, value];
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
  Future<Role?> selectOne(String primaryKeyName, dynamic value) =>
      RoleQuery().select().where().addCustom(primaryKeyName, value).one();

  @override
  Map<String, dynamic> toInsert() => {
        "id": model.id ?? generateUUID(),
        "title": model.title,
      };
}

class RoleMigration extends Migration {
  RoleMigration(super.tableName);

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
          name: 'title',
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
