import 'package:nectar/nectar.dart';

part 'media.g.dart';

@Entity(tableName: "media")
abstract class _MediaEntity {
  @Id()
  @UuidGenerate()
  String? id;

  @Column()
  late String url;

  @Column(name: "is_main")
  late bool isMain;

  @Column()
  late int type;
}
