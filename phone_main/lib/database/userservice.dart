import 'dart:async';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_main/database/user.dart';

class IsarService {
  late Future<Isar> db;
  
  //we define db that we want to use as late
  IsarService() {
    db = openDB();
    //open DB for use.
  }
  
  //Save a new user to the Isar database.
  Future<void> saveUser(User newUser) async {
    final isar = await db;
    //Perform a synchronous write transaction to add the user to the database.
    isar.writeTxnSync(() => isar.users.putSync(newUser));
  }

  //Listen to changes in the user collection and yield a stream of user lists.
  Stream<List<User>> listenUser() async* {
    final isar = await db;
    //Watch the user collection for changes and yield the updated user list.
    yield* isar.users.where().watch(fireImmediately: true);
  }

  // get user by id
  Future<User?> getUserById(int id) async {
    final isar = await db;
    //Find the user with the specified ID in the user collection and return it.
    return await isar.users.get(id);
  }

  // get list of heartrate of user
  Future<List<double>> getHeartRateList(User user) async {
    // ignore: unused_local_variable
    final isar = await db;
    //Find the user with the specified ID in the user collection and return it.
    return user.heartrate ?? [];
  }

  // get last heartrate of user
  Future<double> getLastHeartRate(int id) async {
    final isar = await db;
    //Find the user with the specified ID in the user collection and return the last heart rate.
    return (await isar.users.get(id))?.heartrate?.last ?? 0;
  }

  // get name of user by id
  Future<String> getUserName(int id) async {
    final isar = await db;
    //Find the user with the specified ID in the user collection and return the name.
    return (await isar.users.get(id))?.name ?? '';
  }

  // add heart rate to user(add to heartrate list of user)
  Future<void> addHeartRate(User user, double heartRate) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.users.put(user..heartrate?.add(heartRate));
    });
  }

  //Retrieve all users from the Isar database.
  Future<List<User>> getAllUser() async {
    final isar = await db;
    //Find all users in the user collection and return the list.
    return await isar.users.where().findAll();
  }

  // Update an existing user in the Isar database.
  // ignore: non_constant_identifier_names
  Future<void> UpdateUser(User user) async {
    final isar = await db;
    await isar.writeTxn(() async {
      //Perform a write transaction to update the user in the database.
      await isar.users.put(user);
    });
  }

  //Delete a user from the Isar database based on user ID.
  Future<void> deleteUser(int userid) async {
    final isar = await db;
    //Perform a write transaction to delete the user with the specified ID.
    isar.writeTxn(() => isar.users.delete(userid));
  }

  Future<Isar> openDB() async {
    var dir = await getApplicationDocumentsDirectory();
    // to get application directory information
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        //open isar
        [UserSchema],
        directory: dir.path,
        // user.g.dart includes the schemes that we need to define here - it can be multiple.
      );
    }
    return Future.value(Isar.getInstance());
    // return instance of Isar - it makes the isar state Ready for Usage for adding/deleting operations.
  }
}