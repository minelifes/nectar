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

  @override
  List<String> get columns => ["id", "title"];

  @override
  String get tableName => "Role";

  @override
  void fromRow(Map result) {
    id = result["id"];
    title = result["title"];
  }

  static RoleQuery query() => RoleQuery();

  Future<Role?> save() async => RoleInsertClause(this, () => Role()).insert();

  Future<Role?> update() async => RoleInsertClause(this, () => Role()).update();
}

class RoleQuery extends Query<Role> {
  RoleQuery() : super("Role");

  @override
  Role instanceOfT() => Role();

  @override
  RoleSelectClause select({List<String>? fields}) {
    if (fields != null) {
      model.fields = fields.join(", ");
    }
    return RoleSelectClause(model, instanceOfT);
  }
}

class RoleSelectClause extends SelectClause<Role> {
  RoleSelectClause(super.model, super.instanceOfT);

  @override
  RoleWhereClause where() => RoleWhereClause(model, instanceOfT);
}

class RoleWhereClause extends WhereClause<Role> {
  RoleWhereClause(super.model, super.instanceOfT);

  RoleWhereClause id(String value, {operator = "="}) {
    model.where["id"] = [operator, value];
    return this;
  }

  RoleWhereClause title(String value, {operator = "="}) {
    model.where["title"] = [operator, value];
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
  Map<String, dynamic> toInsert() => {
        "id": model.id,
        "title": model.title,
      };
}
