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
        "role": role
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
    id = result["id"];
    name = result["name"];
    lastName = result["lastName"];
    email = result["email"];
    phone = result["phone"];
    password = result["password"];
    isBlocked = result["isBlocked"];
    role = result["role"];
  }

  static UserQuery query() => UserQuery();

  Future<User?> save() async => UserInsertClause(this, () => User()).insert();

  Future<User?> update() async => UserInsertClause(this, () => User()).update();
}

class UserQuery extends Query<User> {
  UserQuery() : super("User");

  @override
  User instanceOfT() => User();

  @override
  UserSelectClause select({List<String>? fields}) {
    if (fields != null) {
      model.fields = fields.join(", ");
    }
    return UserSelectClause(model, instanceOfT);
  }
}

class UserSelectClause extends SelectClause<User> {
  UserSelectClause(super.model, super.instanceOfT);

  @override
  UserWhereClause where() => UserWhereClause(model, instanceOfT);
}

class UserWhereClause extends WhereClause<User> {
  UserWhereClause(super.model, super.instanceOfT);

  UserWhereClause id(int value, {operator = "="}) {
    model.where["id"] = [operator, value];
    return this;
  }

  UserWhereClause name(String value, {operator = "="}) {
    model.where["name"] = [operator, value];
    return this;
  }

  UserWhereClause lastName(String value, {operator = "="}) {
    model.where["lastName"] = [operator, value];
    return this;
  }

  UserWhereClause email(String value, {operator = "="}) {
    model.where["email"] = [operator, value];
    return this;
  }

  UserWhereClause phone(String value, {operator = "="}) {
    model.where["phone"] = [operator, value];
    return this;
  }

  UserWhereClause password(String value, {operator = "="}) {
    model.where["password"] = [operator, value];
    return this;
  }

  UserWhereClause isBlocked(bool value, {operator = "="}) {
    model.where["isBlocked"] = [operator, value];
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
