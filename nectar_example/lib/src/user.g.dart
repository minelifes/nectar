// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// NectarOrmGenerator
// **************************************************************************

class User extends _User implements Model {
  User();

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "password": password,
        "isBlocked": isBlocked,
        "role": role.toJson()
      };

  factory User.fromJson(Map<String, dynamic> json) => User()
    ..id = json["id"]
    ..name = json["name"]
    ..lastName = json["lastName"]
    ..email = json["email"]
    ..phone = json["phone"]
    ..password = json["password"]
    ..isBlocked = json["isBlocked"]
    ..role = Role.fromJson(json["role"]);

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
  List<String> get columns => [
        "id",
        "name",
        "last_name",
        "email",
        "phone",
        "password",
        "is_blocked",
        "role_id"
      ];

  @override
  String get tableName => "users";

  @override
  void fromRow(Map result) {
    if (result.containsKey('users')) {
      id = result['users']['id'];
    } else {
      id = result['id'];
    }

    if (result.containsKey('users')) {
      name = result['users']['name'];
    } else {
      name = result['name'];
    }

    if (result.containsKey('users')) {
      lastName = result['users']['last_name'];
    } else {
      lastName = result['last_name'];
    }

    if (result.containsKey('users')) {
      email = result['users']['email'];
    } else {
      email = result['email'];
    }

    if (result.containsKey('users')) {
      phone = result['users']['phone'];
    } else {
      phone = result['phone'];
    }

    if (result.containsKey('users')) {
      password = result['users']['password'];
    } else {
      password = result['password'];
    }

    if (result.containsKey('users')) {
      final wisBlocked = result['users']['is_blocked'];
      isBlocked = (wisBlocked == 1) ? true : false;
    } else {
      final wisBlocked = result['is_blocked'];
      isBlocked = (wisBlocked == 1) ? true : false;
    }

    final l_role = (result["roles"] as Map<dynamic, dynamic>?);
    role = (l_role == null || l_role.isNotEmpty != true)
        ? Role()
        : (Role()..fromRow(l_role.values.first));
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

  static UserMigration migration() => UserMigration("users");

  static UserQuery query() => UserQuery();

  Future<User?> save() async =>
      await UserInsertClause(this, () => User()).insert();
}

class UserQuery extends Query<User> {
  UserQuery() : super("users", "id");

  @override
  User instanceOfT() => User();

  List<String> get _defaultTableFields => [
        "users.id as users\$id",
        "users.name as users\$name",
        "users.last_name as users\$last_name",
        "users.email as users\$email",
        "users.phone as users\$phone",
        "users.password as users\$password",
        "users.is_blocked as users\$is_blocked"
      ];

  @override
  UserSelectClause select({
    List<String> fields = const [],
  }) {
    model.fields = (fields.isEmpty) ? _defaultTableFields : fields;
    model.joins = [
      JoinModel(
        tableName: 'users',
        mappedBy: 'role_id',
        foreignTableName: 'roles',
        foreignKey: 'key',
        fields: [
          JoinField(name: 'key', mappedAs: 'roles\$key'),
          JoinField(name: 'name', mappedAs: 'roles\$name')
        ],
      )
    ];
    return UserSelectClause(model, instanceOfT);
  }
}

class UserSelectClause extends SelectClause<User> {
  UserSelectClause(super.model, super.instanceOfT);

  @override
  UserWhereClause where() => UserWhereClause(model, instanceOfT);

  @override
  UserSelectClause join(JoinModel join) {
    model.joins.add(join);
    return this;
  }
}

class UserWhereClause extends WhereClause<User> {
  UserWhereClause(super.model, super.instanceOfT);

  UserWhereClause id(int? value, {operator = "=", condition = "AND"}) {
    model.where["users.id"] = [operator, value, condition];
    return this;
  }

  UserWhereClause name(String value, {operator = "=", condition = "AND"}) {
    model.where["users.name"] = [operator, value, condition];
    return this;
  }

  UserWhereClause lastName(String value, {operator = "=", condition = "AND"}) {
    model.where["users.last_name"] = [operator, value, condition];
    return this;
  }

  UserWhereClause email(String? value, {operator = "=", condition = "AND"}) {
    model.where["users.email"] = [operator, value, condition];
    return this;
  }

  UserWhereClause phone(String value, {operator = "=", condition = "AND"}) {
    model.where["users.phone"] = [operator, value, condition];
    return this;
  }

  UserWhereClause password(String value, {operator = "=", condition = "AND"}) {
    model.where["users.password"] = [operator, value, condition];
    return this;
  }

  UserWhereClause isBlocked(bool value, {operator = "=", condition = "AND"}) {
    model.where["users.is_blocked"] = [operator, value, condition];
    return this;
  }

  UserWhereClause roleKey(String? value, {operator = "=", condition = "AND"}) {
    model.where["users.role_id"] = [operator, value, condition];
    return this;
  }

  UserWhereClause customField(String key, value,
      {operator = "=", condition = "AND"}) {
    model.where[key] = [operator, value, condition];
    return this;
  }

  UserWhereClause customWhere(String where) {
    model.where["_SQL"] = where;
    return this;
  }
}

class UserInsertClause extends InsertClause<User> {
  UserInsertClause(super.model, super.instanceOfT);

  @override
  Future<User?> selectOne(String primaryKeyName, dynamic value) async =>
      (await UserQuery()
              .select()
              .where()
              .addCustom('users.$primaryKeyName', value)
              .list())
          .firstOrNull;

  @override
  Map<String, dynamic> toInsert() => {
        "id": model.id,
        "name": model.name,
        "last_name": model.lastName,
        "email": model.email,
        "phone": model.phone,
        "password": model.password,
        "is_blocked": model.isBlocked,
        "role_id": model.role.key,
      };
}

class UserMigration extends Migration {
  UserMigration(super.tableName);

  @override
  List<ColumnInfo> get columns => [
        ColumnInfo(
          name: 'id',
          columnType: ColumnType.integer,
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
        ),
        ColumnInfo(
          name: 'last_name',
          columnType: ColumnType.text,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'email',
          columnType: ColumnType.text,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: true,
          length: 0,
        ),
        ColumnInfo(
          name: 'phone',
          columnType: ColumnType.text,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'password',
          columnType: ColumnType.text,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'is_blocked',
          columnType: ColumnType.bool,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'role_id',
          columnType: ColumnType.varchar,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        )
      ];
}
