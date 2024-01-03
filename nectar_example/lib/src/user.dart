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

  @Column(name: "last_name")
  late String lastName;

  @Column(nullable: true)
  String? email;

  @Column()
  late String phone;

  @Column()
  late String password;

  @Column()
  bool isBlocked = false;

  @OneToOne(mappedBy: "roleId", referenceClass: "_Role")
  late Role role;

  @OneToMany(mappedBy: "id", referenceClass: "_Book", foreignKey: "user_id")
  List<Book> books = [];
}
