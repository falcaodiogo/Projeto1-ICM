import 'package:isar/isar.dart';
part 'user.g.dart';

@collection
class User {
  User(this.id, this.name, this.heartrate);
  Id? id;
  String? name;
  List<double>? heartrate;
}