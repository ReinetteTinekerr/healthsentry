import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/firebase/firebase_auth_provider.dart';
import 'package:health_sentry/app/core/firebase/firestoredb_provider.dart';
import 'package:health_sentry/app/features/accounts/model/user.dart' as u;
import 'package:health_sentry/app/features/accounts/repository/accounts_repository.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>(
  (ref) => AccountsRepository(db: ref.watch(firestoreProvider)),
);

final accountsStreamProvider =
    StreamProvider.family<QuerySnapshot<u.User>, int>(
  (ref, role) {
    final repo = ref.watch(accountsRepositoryProvider);
    return repo.accountsStream(role: role);
  },
);

final currentUserFutureProvider = FutureProvider(
  (ref) async {
    final currentUser = ref.watch(currentUserStateProvider);
    final repo = ref.watch(accountsRepositoryProvider);
    return repo.getUser(currentUser?.uid ?? "");
  },
);
