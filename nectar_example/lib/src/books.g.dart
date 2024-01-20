// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books.dart';

// **************************************************************************
// NectarOrmGenerator
// **************************************************************************

class Book extends _Book implements Model {
  Book();

  Map<String, dynamic> toJson() => {"id": id, "userId": userId, "title": title};

  factory Book.fromJson(Map<String, dynamic> json) => Book()
    ..id = json["id"]
    ..userId = json["userId"]
    ..title = json["title"];

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
  List<String> get columns => ["id", "user_id", "title"];

  @override
  String get tableName => "books";

  @override
  void fromRow(Map result, Map? allResponse) {
    if (result.containsKey('books')) {
      id = result['books']['books_id'];
    } else {
      id = result['books_id'];
    }

    if (result.containsKey('books')) {
      userId = result['books']['books_user_id'];
    } else {
      userId = result['books_user_id'];
    }

    if (result.containsKey('books')) {
      title = result['books']['books_title'];
    } else {
      title = result['books_title'];
    }
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

  static BookMigration migration() => BookMigration("books");

  static BookQuery query() => BookQuery();

  Future<Book?> save() async =>
      await BookInsertClause(this, () => Book()).insert();
}

class BookQuery extends Query<Book> {
  BookQuery() : super("books", "id");

  @override
  Book instanceOfT() => Book();

  List<String> get _defaultTableFields => [
        "books.id as books_id",
        "books.user_id as books_user_id",
        "books.title as books_title"
      ];

  @override
  BookSelectClause select({
    List<String> fields = const [],
  }) {
    model.fields = (fields.isEmpty) ? _defaultTableFields : fields;
    model.joins = [];
    return BookSelectClause(model, instanceOfT);
  }
}

class BookSelectClause extends SelectClause<Book> {
  BookSelectClause(super.model, super.instanceOfT);

  @override
  BookWhereClause where() => BookWhereClause(model, instanceOfT);

  @override
  BookSelectClause join(JoinModel join) {
    model.joins.add(join);
    return this;
  }
}

class BookWhereClause extends WhereClause<Book> {
  BookWhereClause(super.model, super.instanceOfT);

  BookWhereClause id(int? value, {operator = "="}) {
    model.where["books.id"] = [operator, value];
    return this;
  }

  BookWhereClause userId(int value, {operator = "="}) {
    model.where["books.user_id"] = [operator, value];
    return this;
  }

  BookWhereClause title(String value, {operator = "="}) {
    model.where["books.title"] = [operator, value];
    return this;
  }

  BookWhereClause customField(String key, value, {operator = "="}) {
    model.where[key] = [operator, value];
    return this;
  }
}

class BookInsertClause extends InsertClause<Book> {
  BookInsertClause(super.model, super.instanceOfT);

  @override
  Future<Book?> selectOne(String primaryKeyName, dynamic value) => BookQuery()
      .select()
      .where()
      .addCustom('books.$primaryKeyName', value)
      .one();

  @override
  Map<String, dynamic> toInsert() => {
        "id": model.id,
        "user_id": model.userId,
        "title": model.title,
      };
}

class BookMigration extends Migration {
  BookMigration(super.tableName);

  @override
  List<ColumnInfo> get columns => [
        ColumnInfo(
          name: 'id',
          columnType: ColumnType.integer,
          defaultValue: null,
          isKey: true,
          isAutoIncrement: true,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'user_id',
          columnType: ColumnType.integer,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        ),
        ColumnInfo(
          name: 'title',
          columnType: ColumnType.text,
          defaultValue: null,
          isKey: false,
          isAutoIncrement: false,
          unique: false,
          nullable: false,
          length: 0,
        )
      ];
}
