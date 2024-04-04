import 'dart:async';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_main/database/user.dart';

class IsarService {
  late Future<Isar> db;
  
  IsarService() {
    db = openDB();
    // open DB for use.
  }
  
  // Save a new user to the Isar database.
  Future<void> saveUser(User newUser) async {
    final isar = await db;
    // Perform a synchronous write transaction to add the user to the database.
    isar.writeTxnSync(() => isar.users.putSync(newUser));
  }

  // Listen to changes in the user collection and yield a stream of user lists.
  Stream<List<User>> listenUser() async* {
    final isar = await db;
    //Watch the user collection for changes and yield the updated user list.
    yield* isar.users.where().watch(fireImmediately: true);
  }

  // Add heart rate to user(add to heartrate list of user)
  Future<void> addHeartRate(User user, double heartRate) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.users.put(user..heartrate?.add(heartRate));
    });
  }

  // Retrieve all users from the Isar database.
  Future<List<User>> getAllUser() async {
    final isar = await db;
    return await isar.users.where().findAll();
  }

  // clean all users from the Isar database.
  Future<void> cleanAllUser() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.users.clear();
    });
  }

  Future<Isar> openDB() async {
    var dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [UserSchema],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
    // return instance of Isar - it makes the isar state Ready for Usage for adding/deleting operations.
  }
}