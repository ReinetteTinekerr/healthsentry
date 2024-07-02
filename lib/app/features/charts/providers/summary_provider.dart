import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/records/providers/records_provider.dart';

final currentDateSummaryStateProvider = StateProvider((ref) => DateTime.now());

final healthStatusSummaryFutureProvider = FutureProvider(
  (ref) {
    final repo = ref.watch(recordsProvider);
    final currentDateState = ref.watch(currentDateSummaryStateProvider);
    return repo.getSummaryByYear(date: currentDateState);
  },
);
