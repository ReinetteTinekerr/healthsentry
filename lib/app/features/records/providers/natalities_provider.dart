import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/records/providers/records_provider.dart';

final currentDateNatalitiesProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final natalitiesStreamProvider = StreamProvider(
  (ref) {
    final repo = ref.watch(recordsProvider);
    final currentDate = ref.watch(currentDateNatalitiesProvider);
    return repo.natalitiesStream(date: currentDate);
  },
);

// final recordsNatalityStream = StreamProvider<List<Natality>>((ref) {
//   final repo = ref.watch(recordsProvider);
//   final limit = 10;

//   final initialStream = Stream.fromFuture(Future.value([]));
//   final pageStream = initialStream.asyncExpand(
//     (_) => repo.getNatality(limit, null),
//   ).asyncExpand((natalities) => repo.getNatality(limit, natalities.isEmpty? natalities.last.id: null));
// });
