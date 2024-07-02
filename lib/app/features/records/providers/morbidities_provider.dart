import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/records/providers/records_provider.dart';

final currentDateMorbiditiesProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final morbiditiesStreamProvider = StreamProvider(
  (ref) {
    final repo = ref.watch(recordsProvider);
    final currentDate = ref.watch(currentDateMorbiditiesProvider);
    return repo.morbiditiesStream(date: currentDate);
  },
);
