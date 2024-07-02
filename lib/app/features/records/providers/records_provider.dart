import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/firebase/firestoredb_provider.dart';
import 'package:health_sentry/app/features/records/repository/records_repository.dart';

final recordsProvider = Provider(
  (ref) => RecordsRepository(db: ref.watch(firestoreProvider)),
);
