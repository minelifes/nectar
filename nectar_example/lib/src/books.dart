import 'package:nectar/nectar.dart';

part 'books.g.dart';

@Entity(tableName: "books")
class _Book {
  @Id()
  @AutoIncrement()
  int? id;

  @Column(name: "user_id")
  late int userId;

  @Column(name: "title")
  late String title;
}
