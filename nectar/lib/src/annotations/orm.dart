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
  blob;

  String getSqlType(int length) {
    switch (this) {
      case ColumnType.integer:
        return "${length > 11 ? "bigint" : "int"}(${length > 0 ? length : 11})";
      case ColumnType.bool:
        return "tinyint";
      case ColumnType.float:
        return "float(${length > 0 ? length : 11}, 2)";
      case ColumnType.double:
        return "double(${length > 0 ? length : 11}, 2)";
      case ColumnType.text:
        return "text${length > 0 ? "($length)" : ""}";
      case ColumnType.varchar:
        return "varchar${length > 0 ? "($length)" : "(255)"}";
      default:
        return "blob${length > 0 ? "($length)" : ""}";
    }
  }
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
  final dynamic defaultValue;

  const Column({
    this.name,
    this.columnType,
    this.length,
    this.defaultValue,
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
  final String mappedBy;
  final String foreignKey;
  final String referenceClass;
  const OneToOne({
    required this.referenceClass,
    required this.mappedBy,
    this.foreignKey = "id",
  });
}

class OneToMany {
  final String mappedBy;
  final String foreignKey;
  final String referenceClass;
  const OneToMany({
    required this.referenceClass,
    required this.mappedBy,
    this.foreignKey = "id",
  });
}

class ManyToOne {
  final String mappedBy;
  final String foreignKey;
  final String referenceClass;
  const ManyToOne({
    required this.referenceClass,
    required this.mappedBy,
    this.foreignKey = "id",
  });
}

class PostLoad {
  const PostLoad();
}

class PreLoad {
  const PreLoad();
}

class UuidGenerate {
  const UuidGenerate();
}

class AutoIncrement {
  const AutoIncrement();
}

class EnumColumn {
  final String? name;
  const EnumColumn({this.name});
}
