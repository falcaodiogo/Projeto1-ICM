import 'package:isar/isar.dart';
part 'user.g.dart';

@collection
class User {
  User(this.id, this.name, this.heartRate);
  Id? id;
  String? name;
  double? heartRate;
}