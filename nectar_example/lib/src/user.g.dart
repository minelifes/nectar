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
        "role": role?.toJson(),
        "books": books?.map(_valueForList).toList()
      };

  factory User.fromJson(Map<String, dynamic> json) => User()
    ..id = json["id"]
    ..name = json["name"]
    ..lastName = json["lastName"]
    ..email = json["email"]
    ..phone = json["phone"]
    ..password = json["password"]
    ..isBlocked = json["isBlocked"]
    ..role = Role.fromJson(json["role"])
    ..books =
        (json["books"] as List<dynamic>).map((e) => Book.fromJson(e)).toList();

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
        "isBlocked",
        "roleId",
        "id"
      ];

  @override
  String get tableName => "User";

  @override
  void fromRow(Map result) {
    if (result.containsKey('User')) {
      id = result['User']['User_id'];
    } else {
      id = result['User_id'];
    }

    if (result.containsKey('User')) {
      name = result['User']['User_name'];
    } else {
      name = result['User_name'];
    }

    if (result.containsKey('User')) {
      lastName = result['User']['User_last_name'];
    } else {
      lastName = result['User_last_name'];
    }

    if (result.containsKey('User')) {
      email = result['User']['User_email'];
    } else {
      email = result['User_email'];
    }

    if (result.containsKey('User')) {
      phone = result['User']['User_phone'];
    } else {
      phone = result['User_phone'];
    }

    if (result.containsKey('User')) {
      password = result['User']['User_password'];
    } else {
      password = result['User_password'];
    }

    if (result.containsKey('User')) {
      final wisBlocked = result['User']['User_isBlocked'];
      isBlocked = (wisBlocked == 1) ? true : false;
    } else {
      final wisBlocked = result['User_isBlocked'];
      isBlocked = (wisBlocked == 1) ? true : false;
    }

    final l_role = (result["Role"] as List<Map<String, dynamic>>?);
    role = (l_role == null ||
            l_role.isNotEmpty != true ||
            l_role.firstOrNull?.isNotEmpty != true)
        ? Role()
        : (Role()..fromRow(l_role.first));

    books =
        (result["books"] as List?)?.map((e) => Book()..fromRow(e)).toList() ??
            [];
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

  static UserMigration migration() => UserMigration("User");

  static UserQuery query() => UserQuery();

  Future<User?> save() async =>
      await UserInsertClause(this, () => User()).insert();
}

class UserQuery extends Query<User> {
  UserQuery() : super("User", "id");

  @override
  User instanceOfT() => User();

  List<String> get _defaultTableFields => [
        "User.id as User_id",
        "User.name as User_name",
        "User.last_name as User_last_name",
        "User.email as User_email",
        "User.phone as User_phone",
        "User.password as User_password",
        "User.isBlocked as User_isBlocked"
      ];

  @override
  UserSelectClause select({
    List<String> fields = const [],
  }) {
    model.fields = (fields.isEmpty) ? _defaultTableFields : fields;
    model.joins = [
      JoinModel(
        tableName: 'User',
        mappedBy: 'roleId',
        foreignTableName: 'Role',
        foreignKey: 'id',
        fields: ["Role.id as Role_id", "Role.title as Role_title"],
      ),
      JoinModel(
        tableName: 'User',
        mappedBy: 'id',
        foreignTableName: 'books',
        foreignKey: 'user_id',
        fields: [
          "books.id as books_id",
          "books.user_id as books_user_id",
          "books.title as books_title"
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

  UserWhereClause id(int? value, {operator = "="}) {
    model.where["User.id"] = [operator, value];
    return this;
  }

  UserWhereClause name(String value, {operator = "="}) {
    model.where["User.name"] = [operator, value];
    return this;
  }

  UserWhereClause lastName(String value, {operator = "="}) {
    model.where["User.last_name"] = [operator, value];
    return this;
  }

  UserWhereClause email(String? value, {operator = "="}) {
    model.where["User.email"] = [operator, value];
    return this;
  }

  UserWhereClause phone(String value, {operator = "="}) {
    model.where["User.phone"] = [operator, value];
    return this;
  }

  UserWhereClause password(String value, {operator = "="}) {
    model.where["User.password"] = [operator, value];
    return this;
  }

  UserWhereClause isBlocked(bool value, {operator = "="}) {
    model.where["User.isBlocked"] = [operator, value];
    return this;
  }

  UserWhereClause roleId(String? value, {operator = "="}) {
    model.where["User.roleId"] = [operator, value];
    return this;
  }

  UserWhereClause bookId(int? value, {operator = "="}) {
    model.where["User.id"] = [operator, value];
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
  Future<User?> selectOne(String primaryKeyName, dynamic value) => UserQuery()
      .select()
      .where()
      .addCustom('User.$primaryKeyName', value)
      .one();

  @override
  Map<String, dynamic> toInsert() => {
        "id": model.id,
        "name": model.name,
        "last_name": model.lastName,
        "email": model.email,
        "phone": model.phone,
        "password": model.password,
        "isBlocked": model.isBlocked,
        "roleId": model.role?.id,
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
          name: 'isBlocked',
          columnType: ColumnType.bool,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'roleId',
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
