import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/records/providers/records_provider.dart';

final currentDateMortalitiesProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final mortalitiesStreamProvider = StreamProvider(
  (ref) {
    final repo = ref.watch(recordsProvider);
    final currentDate = ref.watch(currentDateMortalitiesProvider);
    return repo.mortalitiesStream(date: currentDate);
  },
);
