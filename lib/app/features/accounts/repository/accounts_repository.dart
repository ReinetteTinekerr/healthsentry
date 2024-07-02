import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sentry/app/features/accounts/model/user.dart';

class AccountsRepository {
  final FirebaseFirestore db;

  AccountsRepository({required this.db});

  Future<DocumentReference<User>> addUser(User user) async {
    final userRef =
        db.collection(User.userString).doc(user.userId).withConverter(
              fromFirestore: User.fromFirestore,
              toFirestore: (value, options) => value.toFirestore(),
            );
    await userRef.set(user);
    return userRef;
  }

  Future<User?> getUser(String userId) async {
    final userRef = db.collection(User.userString).doc(userId).withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (value, options) => value.toFirestore(),
        );
    final user = await userRef.get();
    return user.data();
  }

  Future<void> updateUsername(String userId, String newUsername) async {
    final userRef = db.collection(User.userString).doc(userId);
    await userRef.update({"username": newUsername});
  }

  Stream<QuerySnapshot<User>> accountsStream({required int role}) async* {
    var query = db
        .collection(User.userString)
        .orderBy('timestamp')
        .where('role', isEqualTo: role)
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (value, options) => value.toFirestore(),
        );
    yield* query.snapshots();
  }
}
