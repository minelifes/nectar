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
    ..role = json["role"];

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
    if (e is List) {
      return _valueForList(e);
    }
    return e.toJson();
  }

  @override
  List<String> get columns => [
        "id",
        "name",
        "lastName",
        "email",
        "phone",
        "password",
        "isBlocked",
        "role"
      ];

  @override
  String get tableName => "User";

  @override
  void fromRow(Map result) {
    id = result['User_id'];

    name = result['User_name'];

    lastName = result['User_lastName'];

    email = result['User_email'];

    phone = result['User_phone'];

    password = result['User_password'];

    isBlocked = result['User_isBlocked'];

    role = Role()..fromRow(result);
  }

  static UserQuery query() => UserQuery();

  Future<User?> save() async => UserInsertClause(this, () => User()).insert();

  Future<User?> update() async => UserInsertClause(this, () => User()).update();
}

class UserQuery extends Query<User> {
  UserQuery() : super("User");

  @override
  User instanceOfT() => User();

  List<String> get _defaultTableFields => [
        "User.id as User_id",
        "User.name as User_name",
        "User.lastName as User_lastName",
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
    model.where["User.lastName"] = [operator, value];
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
    model.where["User.role"] = [operator, value];
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
  Map<String, dynamic> toInsert() => {
        "id": model.id,
        "name": model.name,
        "lastName": model.lastName,
        "email": model.email,
        "phone": model.phone,
        "password": model.password,
        "isBlocked": model.isBlocked,
        "role": model.role,
      };
}
