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
  void fromRow(Map result, Map? allResponse) {
    if (result.containsKey('users')) {
      id = result['users']['users_id'];
    } else if (result.containsKey('users\$id') == true) {
      id = result['users\$id'];
    } else if (allResponse?.containsKey('users\$id') == true) {
      id = allResponse!['users\$id'];
    } else {
      id = allResponse!['users'].first['users\$id'];
    }

    if (result.containsKey('users')) {
      name = result['users']['users_name'];
    } else if (result.containsKey('users\$name') == true) {
      name = result['users\$name'];
    } else if (allResponse?.containsKey('users\$name') == true) {
      name = allResponse!['users\$name'];
    } else {
      name = allResponse!['users'].first['users\$name'];
    }

    if (result.containsKey('users')) {
      lastName = result['users']['users_last_name'];
    } else if (result.containsKey('users\$last_name') == true) {
      lastName = result['users\$last_name'];
    } else if (allResponse?.containsKey('users\$last_name') == true) {
      lastName = allResponse!['users\$last_name'];
    } else {
      lastName = allResponse!['users'].first['users\$last_name'];
    }

    if (result.containsKey('users')) {
      email = result['users']['users_email'];
    } else if (result.containsKey('users\$email') == true) {
      email = result['users\$email'];
    } else if (allResponse?.containsKey('users\$email') == true) {
      email = allResponse!['users\$email'];
    } else {
      email = allResponse!['users'].first['users\$email'];
    }

    if (result.containsKey('users')) {
      phone = result['users']['users_phone'];
    } else if (result.containsKey('users\$phone') == true) {
      phone = result['users\$phone'];
    } else if (allResponse?.containsKey('users\$phone') == true) {
      phone = allResponse!['users\$phone'];
    } else {
      phone = allResponse!['users'].first['users\$phone'];
    }

    if (result.containsKey('users')) {
      password = result['users']['users_password'];
    } else if (result.containsKey('users\$password') == true) {
      password = result['users\$password'];
    } else if (allResponse?.containsKey('users\$password') == true) {
      password = allResponse!['users\$password'];
    } else {
      password = allResponse!['users'].first['users\$password'];
    }

    if (result.containsKey('users')) {
      final wisBlocked = result['users']['users_is_blocked'];
      isBlocked = (wisBlocked == 1) ? true : false;
    } else if (result.containsKey('users\$is_blocked') == true) {
      final wisBlocked = result['users\$is_blocked'];
      isBlocked = (wisBlocked == 1) ? true : false;
    } else if (allResponse?.containsKey('users\$is_blocked') == true) {
      final wisBlocked = allResponse!['users\$is_blocked'];
      isBlocked = (wisBlocked == 1) ? true : false;
    } else {
      final wisBlocked = allResponse!['users'].first['users\$is_blocked'];
      isBlocked = (wisBlocked == 1) ? true : false;
    }

    final l_role = (result["roles"] as List<Map<String, dynamic>>?) ??
        (allResponse?["roles"] as List<Map<String, dynamic>>?);
    role = (l_role == null ||
            l_role.isNotEmpty != true ||
            l_role.firstOrNull?.isNotEmpty != true)
        ? Role()
        : (Role()..fromRow(l_role.first, allResponse));
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
        fields: ["roles.key as roles\$key", "roles.name as roles\$name"],
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

  UserWhereClause id(int? value, {operator = "="}) {
    model.where["users.id"] = [operator, value];
    return this;
  }

  UserWhereClause name(String value, {operator = "="}) {
    model.where["users.name"] = [operator, value];
    return this;
  }

  UserWhereClause lastName(String value, {operator = "="}) {
    model.where["users.last_name"] = [operator, value];
    return this;
  }

  UserWhereClause email(String? value, {operator = "="}) {
    model.where["users.email"] = [operator, value];
    return this;
  }

  UserWhereClause phone(String value, {operator = "="}) {
    model.where["users.phone"] = [operator, value];
    return this;
  }

  UserWhereClause password(String value, {operator = "="}) {
    model.where["users.password"] = [operator, value];
    return this;
  }

  UserWhereClause isBlocked(bool value, {operator = "="}) {
    model.where["users.is_blocked"] = [operator, value];
    return this;
  }

  UserWhereClause roleKey(String? value, {operator = "="}) {
    model.where["users.role_id"] = [operator, value];
    return this;
  }

  UserWhereClause customField(String key, value, {operator = "="}) {
    model.where[key] = [operator, value];
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
