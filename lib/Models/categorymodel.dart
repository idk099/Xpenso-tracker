import 'package:hive/hive.dart';

part 'categorymodel.g.dart'; // This is the generated file by Hive

@HiveType(typeId: 0)
class Category extends HiveObject {

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int icon;

  Category({required this.id,required this.name, required this.icon});
}
