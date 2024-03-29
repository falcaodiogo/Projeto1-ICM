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

  //Retrieve all users from the Isar database.
  Future<List<User>> getAllUser() async {
    final isar = await db;
    //Find all users in the user collection and return the list.
    return await isar.users.where().findAll();
  }

  // Update an existing user in the Isar database.
  Future<void> updateUser(User user) async {
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

  // delete all
  Future<void> deleteAll() async {
    final isar = await db;
    // list 1 to 100
    List<int> list = List.generate(100, (index) => index + 1);
    //Perform a write transaction to delete all users from the database.
    isar.writeTxn(() => isar.users.deleteAll(list));
  }

  // //Filter users based on name containing "test" and age equal to 45. It can be (should be) modified as dynamic.
  // Future<User?> filterName() async {
  //   final isar = await db;
  //   //Use the Isar query API to filter users based on specific criteria and return the first matching result.
  //   final favorites = await isar.users
  //       .filter()
  //       .nameContains("test")
  //       .ageEqualTo(45)
  //       .findFirst();
  //   return favorites;
  // }

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