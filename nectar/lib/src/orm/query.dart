import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:nectar/nectar.dart';

typedef TInstance<T extends Model> = T Function();

class JoinField {
  final String name;
  final String mappedAs;

  JoinField({required this.name, required this.mappedAs});
}

class JoinModel {
  final String tableName;
  final String mappedBy;
  final String foreignKey;
  final String foreignTableName;
  final List<JoinField> fields;

  const JoinModel({
    required this.tableName,
    required this.mappedBy,
    required this.foreignTableName,
    required this.foreignKey,
    required this.fields,
  });
}

class QueryModel {
  String primaryKey = "";
  String tableName = "";
  List<String> fields = [];
  String order = "";
  Map<String, dynamic> where = {};
  String limit = "";
  String group = "";
  List<JoinModel> joins = [];

  QueryModel({
    required this.tableName,
    required this.primaryKey,
  });
}

abstract class Query<T extends Model> {
  late QueryModel model;

  Query(String tableName, String primaryKey) {
    model = QueryModel(tableName: tableName, primaryKey: primaryKey);
  }

  T instanceOfT();

  SelectClause<T> select({
    List<String> fields = const [],
  }); //=> SelectClause(_model, instanceOfT, fields: fields)
}

abstract class SelectClause<T extends Model> extends ExecClause<T> {
  SelectClause(super.model, super.instanceOfT);

  WhereClause<T> where(); // => WhereClause(_model, _instanceOfT)
  SelectClause<T> join(JoinModel join);
}

abstract class WhereClause<T extends Model> extends ExecClause<T> {
  WhereClause(super._model, super.instanceOfT);

  WhereClause<T> addCustom(String key, dynamic value, {String operator = "="}) {
    model.where[key] = [operator, value];
    return this;
  }
}

abstract class ExecClause<T extends Model> {
  QueryModel model;
  TInstance<T> instanceOfT;

  ExecClause(this.model, this.instanceOfT);

  Future<List<T>> list({int limit = 20, int startFrom = 0}) async {
    var results = await GetIt.I.get<Db>().getAll(
          table: model.tableName,
          fields: model.fields,
          where: model.where,
          joins: model.joins,
          limit: limit,
          startFrom: startFrom,
        );

    return results.mapIndexed((i, e) => instanceOfT()..fromRow(e)).toList();
  }

  Future<Paginated> paginated({required int page, int perPage = 20}) async {
    var results = await GetIt.I.get<Db>().paginated<T>(
        table: model.tableName,
        fields: model.fields,
        where: model.where,
        joins: model.joins,
        instanceOfT: (e) => instanceOfT()..fromRow(e),
        perPage: perPage,
        page: page);
    return results;
  }

  Future<int> delete() => GetIt.I.get<Db>().delete(
        table: model.tableName,
        where: model.where,
      );

  Future<T?> one() async {
    var results = await GetIt.I.get<Db>().getOne(
        table: model.tableName,
        fields: model.fields,
        where: model.where,
        joins: model.joins);
    if (results.isNotEmpty) {
      return instanceOfT()..fromRow(results);
    }
    return null;
  }
}

abstract class InsertClause<T extends Model> {
  T model;
  TInstance<T> instanceOfT;

  InsertClause(this.model, this.instanceOfT);

  Map<String, dynamic> toInsert();

  Future<T?> selectOne(String primaryKeyName, dynamic value);

  Future<T?> insert() async {
    var results = await getIt.get<Db>().insertOrUpdate(
          primaryKeyName: model.primaryKeyName,
          table: model.tableName,
          insertData: toInsert(),
        );
    if (results == null) {
      throw OrmException("Failed to insert data.");
    }

    var value = results;
    if (results is String) {
      value = results.isNotEmpty ? results : toInsert()[model.primaryKeyName];
    }

    return await selectOne(model.primaryKeyName, value);

    ///await query.select().where().addCustom(model.primaryKeyName, "").one();
  }
}

abstract class Migration {
  final String tableName;

  Migration(this.tableName);

  List<ColumnInfo> get columns;

  Future<bool> createTable() async {
    try {
      await getIt
          .get<Db>()
          .createTableIfNotExist(tableName: tableName, columns: columns);
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }
}
