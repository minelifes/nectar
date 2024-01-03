import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nectar/nectar.dart';
import 'package:nectar/src/db/db.dart';
import 'package:nectar/src/exceptions/orm_exception.dart';
import 'package:nectar/src/orm/model.dart';

typedef TInstance<T extends Model> = T Function();

class JoinModel {
  final String tableName;
  final String mappedBy;
  final String foreignKey;
  final String foreignTableName;
  final List<String> fields;
  const JoinModel({
    required this.tableName,
    required this.mappedBy,
    required this.foreignTableName,
    required this.foreignKey,
    required this.fields,
  });
}

class QueryModel {
  String tableName = "";
  List<String> fields = [];
  String order = "";
  Map<String, dynamic> where = {};
  String limit = "";
  String group = "";
  List<JoinModel> joins = [];

  QueryModel({
    required this.tableName,
  });
}

abstract class Query<T extends Model> {
  late QueryModel model;

  Query(String tableName) {
    model = QueryModel(tableName: tableName);
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
}

abstract class ExecClause<T extends Model> {
  QueryModel model;
  TInstance<T> instanceOfT;
  ExecClause(this.model, this.instanceOfT);

  Future<List<T>> list() async {
    var results = await GetIt.I.get<Db>().getAll(
          table: model.tableName,
          fields: model.fields,
          where: model.where,
          joins: model.joins,
        );

    return results.map((e) => instanceOfT()..fromRow(e)).toList();
  }

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

  Future<T?> insert() async {
    var results = await GetIt.I.get<Db>().insert(
          table: model.tableName,
          insertData: toInsert(),
        );
    if (results == null) {
      throw OrmException("Failed to insert data.");
    }
    return instanceOfT()..fromRow(results);
  }

  Future<T?> update() async {
    var results = await GetIt.I.get<Db>().insert(
          table: model.tableName,
          insertData: toInsert(),
        );
    if (results == null) {
      throw OrmException("Failed to update data.");
    }
    return instanceOfT()..fromRow(results);
  }
}

abstract class Migration {
  final String tableName;
  Migration(this.tableName);

  List<ColumnInfo> get columns;

  Future<bool> createTable() async {
    try {
      await GetIt.I
          .get<Db>()
          .createTableIfNotExist(tableName: tableName, columns: columns);
      return true;
    } catch (e) {
      Logger().e(e);
      return false;
    }
  }
}
