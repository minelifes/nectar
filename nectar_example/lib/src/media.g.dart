// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// NectarOrmGenerator
// **************************************************************************

class MediaEntity extends _MediaEntity implements Model {
  MediaEntity();

  Map<String, dynamic> toJson() =>
      {"id": id, "url": url, "isMain": isMain, "type": type};

  factory MediaEntity.fromJson(Map<String, dynamic> json) => MediaEntity()
    ..id = json["id"]
    ..url = json["url"]
    ..isMain = json["isMain"]
    ..type = json["type"];

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
  List<String> get columns => ["id", "url", "is_main", "type"];

  @override
  String get tableName => "media";

  @override
  void fromRow(Map result) {
    if (result.containsKey('media')) {
      id = result['media']['id'];
    } else {
      id = result['id'];
    }

    if (result.containsKey('media')) {
      url = result['media']['url'];
    } else {
      url = result['url'];
    }

    if (result.containsKey('media')) {
      final wisMain = result['media']['is_main'];
      isMain = (wisMain == 1) ? true : false;
    } else {
      final wisMain = result['is_main'];
      isMain = (wisMain == 1) ? true : false;
    }

    if (result.containsKey('media')) {
      type = result['media']['type'];
    } else {
      type = result['type'];
    }
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

  static MediaEntityMigration migration() => MediaEntityMigration("media");

  static MediaEntityQuery query() => MediaEntityQuery();

  Future<MediaEntity?> save() async =>
      await MediaEntityInsertClause(this, () => MediaEntity()).insert();
}

class MediaEntityQuery extends Query<MediaEntity> {
  MediaEntityQuery() : super("media", "id");

  @override
  MediaEntity instanceOfT() => MediaEntity();

  List<String> get _defaultTableFields => [
        "media.id as media\$id",
        "media.url as media\$url",
        "media.is_main as media\$is_main",
        "media.type as media\$type"
      ];

  @override
  MediaEntitySelectClause select({
    List<String> fields = const [],
  }) {
    model.fields = (fields.isEmpty) ? _defaultTableFields : fields;
    model.joins = [];
    return MediaEntitySelectClause(model, instanceOfT);
  }
}

class MediaEntitySelectClause extends SelectClause<MediaEntity> {
  MediaEntitySelectClause(super.model, super.instanceOfT);

  @override
  MediaEntityWhereClause where() => MediaEntityWhereClause(model, instanceOfT);

  @override
  MediaEntitySelectClause join(JoinModel join) {
    model.joins.add(join);
    return this;
  }
}

class MediaEntityWhereClause extends WhereClause<MediaEntity> {
  MediaEntityWhereClause(super.model, super.instanceOfT);

  MediaEntityWhereClause id(String? value,
      {operator = "=", condition = "AND"}) {
    model.where["media.id"] = [operator, value, condition];
    return this;
  }

  MediaEntityWhereClause url(String value,
      {operator = "=", condition = "AND"}) {
    model.where["media.url"] = [operator, value, condition];
    return this;
  }

  MediaEntityWhereClause isMain(bool value,
      {operator = "=", condition = "AND"}) {
    model.where["media.is_main"] = [operator, value, condition];
    return this;
  }

  MediaEntityWhereClause type(int value, {operator = "=", condition = "AND"}) {
    model.where["media.type"] = [operator, value, condition];
    return this;
  }

  MediaEntityWhereClause customField(String key, value,
      {operator = "=", condition = "AND"}) {
    model.where[key] = [operator, value, condition];
    return this;
  }

  MediaEntityWhereClause customWhere(String where) {
    model.where["_SQL"] = where;
    return this;
  }
}

class MediaEntityInsertClause extends InsertClause<MediaEntity> {
  MediaEntityInsertClause(super.model, super.instanceOfT);

  @override
  Future<MediaEntity?> selectOne(String primaryKeyName, dynamic value) async =>
      (await MediaEntityQuery()
              .select()
              .where()
              .addCustom('media.$primaryKeyName', value)
              .list())
          .firstOrNull;

  @override
  Map<String, dynamic> toInsert() => {
        "id": model.id ?? generateUUID(),
        "url": model.url,
        "is_main": model.isMain,
        "type": model.type,
      };
}

class MediaEntityMigration extends Migration {
  MediaEntityMigration(super.tableName);

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
          name: 'url',
          columnType: ColumnType.text,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'is_main',
          columnType: ColumnType.bool,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'type',
          columnType: ColumnType.integer,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        )
      ];
}
