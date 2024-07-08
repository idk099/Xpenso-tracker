import 'package:hive/hive.dart';

part 'accountmodel.g.dart'; // This is the generated file by Hive

@HiveType(typeId: 4)
class Accounts extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int icon;

  @HiveField(3)
  late double bal;

  @HiveField(4)
  late double initbal;

  Accounts({required this.id, required this.name, required this.icon,required this.bal,required this.initbal});
}
