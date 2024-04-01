import 'package:nectar/nectar.dart';

import 'role.dart';

part 'user.g.dart';

@Entity(tableName: "users")
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

  @Column(name: "is_blocked")
  bool isBlocked = false;

  @OneToOne(mappedBy: "role_id", referenceClass: "_Role", foreignKey: "key")
  late Role role;

  @OneToOne(mappedBy: "role_id_2", referenceClass: "_Role", foreignKey: "key")
  late Role role2;
}
