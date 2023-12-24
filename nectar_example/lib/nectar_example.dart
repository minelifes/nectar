import 'package:nectar/nectar.dart';
import 'package:nectar_example/src/test_entity.dart';
import 'package:uuid/uuid.dart';

late Db db;
void createDbConnection() {
  db = Db()
    ..connect(DbSettings(
      host: "localhost",
      user: "root",
      password: "apppassword",
      db: "appdb",
      debug: true,
    ));
}

void main() async {
  createDbConnection();
  final test = await Test.query().select().list();

  print(test);

  final toSave = Test()
    ..id = "asd"
    ..testString = "test3";

  final tt = await toSave.save();

  print(tt);

  //one to one / many to one
  final q = await db.query(
      "Select User.id as User_id, User.name as User_name, User.lastName as User_lastName, User.email as User_email, User.phone as User_phone, User.password as User_password, User.isBlocked as User_isBlocked, User.roleId as User_roleId, Role.id as Role_id, Role.title as Role_title from User INNER JOIN Role on Role.id = User.roleId where User.id = 2");
  print(q.toMap());
  print(q.rows);

  //one to many
  final many = await db.query(
      "Select User.id as User_id, User.name as User_name, User.lastName as User_lastName, User.email as User_email, User.phone as User_phone, User.password as User_password, User.isBlocked as User_isBlocked, User.roleId as User_roleId, books.id as Books_id, books.title as Books_title, books.user_id as Books_userId from User INNER JOIN books on books.user_id = User.id where User.id = 2");
  print(many.toMap());
  print(many.rows);

  db.close();
}
