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
  const Id();
}

class OneToOne {
  final String? mappedBy;
  const OneToOne({this.mappedBy});
}

class OneToMany {
  final String? mappedBy;
  const OneToMany({this.mappedBy});
}

class ManyToOne {
  final String? mappedBy;
  const ManyToOne({this.mappedBy});
}

class PostLoad {
  const PostLoad();
}
