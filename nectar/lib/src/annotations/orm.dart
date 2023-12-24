class Entity {
  final String? tableName;

  const Entity({this.tableName});
}

enum ColumnType {
  integer,
  bool,
  float,
  double,
  text,
  varchar,
  blob,
}

class Column {
  final String? name;
  final ColumnType? columnType;
  final int? length;
  final bool unique;
  final bool nullable;
  final bool insertable;
  final bool updatable;
  final bool serializable;

  const Column({
    this.name,
    this.columnType,
    this.length,
    this.unique = false,
    this.nullable = false,
    this.insertable = true,
    this.updatable = true,
    this.serializable = true,
  });
}

class CreatedAt {
  const CreatedAt();
}

class UpdatedAt {
  const UpdatedAt();
}

class Id {
  final String? name;
  const Id({this.name});
}

class OneToOne {
  final String? mappedBy;
  final String foreignKey;
  const OneToOne({this.mappedBy, this.foreignKey = "id"});
}

class OneToMany {
  final String? mappedBy;
  final String foreignKey;
  const OneToMany({this.mappedBy, this.foreignKey = "id"});
}

class ManyToOne {
  final String? mappedBy;
  final String foreignKey;
  const ManyToOne({this.mappedBy, this.foreignKey = "id"});
}

class PostLoad {
  const PostLoad();
}

class PreLoad {
  const PreLoad();
}

class UuidGenerate{
  const UuidGenerate();
}

class AutoIncrement{
  const AutoIncrement();
}
