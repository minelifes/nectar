import 'package:nectar/nectar.dart';

import 'books.dart';
import 'role.dart';

part 'user.g.dart';

@Entity(tableName: "User")
class _User {
  @Id()
  int? id;

  @Column()
  late String name;

  @Column()
  late String lastName;

  @Column()
  String? email;

  @Column()
  late String phone;

  @Column()
  late String password;

  @Column()
  bool isBlocked = false;

  @Column()
  @OneToOne(mappedBy: "roleId", referenceClass: "_Role")
  late Role role;

  @Column()
  @OneToMany(mappedBy: "id", referenceClass: "_Book", foreignKey: "user_id")
  List<Book> books = [];
}
