import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m3;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_sentry/app/core/utils/enums.dart';
import 'package:health_sentry/app/core/widgets/health_status_button.dart';
import 'package:health_sentry/app/features/charts/local_data/months.dart';
import 'package:health_sentry/app/features/charts/providers/summary_provider.dart';
import 'package:health_sentry/app/features/main/widget/map_widget.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});
  static const routeName = '/main';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  DateTime? selectedDate;
  Set<HealthStatus> selectedHealthStatus = {HealthStatus.morbidity};

  int sliderValue = 0;
  bool hasSliderInitialValue = false;
  HealthStatus previousHealthStatus = HealthStatus.morbidity;
  String selectedBarangay = '';

  @override
  void initState() {
    selectedDate = ref.read(currentDateSummaryStateProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final healthStatusSummary = ref.watch(healthStatusSummaryFutureProvider);
    final Map<String, dynamic> barangayHealthStatus = {};
    final List<String> sliderMonths = [];

    healthStatusSummary.maybeWhen(
      data: (data) {
        final summaryData = data.data();
        if (summaryData == null) return;
        for (final healthStatus in summaryData.entries) {
          // key = month
          for (final monthlySummary in healthStatus.value.entries) {
            // key = mortality/morbidity/natality
            if (monthlySummary.key.toString() ==
                selectedHealthStatus.single.name.toUpperCase()) {
              sliderMonths.add(healthStatus.key);
            }
            for (final barangays in monthlySummary.value.entries) {
              if (barangays.value is Map<String, dynamic>) {
                for (final barangay in barangays.value.entries) {
                  // key = barangay

                  barangayHealthStatus[barangay.key] =
                      barangayHealthStatus[barangay.key] ?? {};

                  barangayHealthStatus[barangay.key][healthStatus.key] =
                      barangayHealthStatus[barangay.key][healthStatus.key] ??
                          {};

                  barangayHealthStatus[barangay.key][healthStatus.key]
                      [monthlySummary.key] = barangayHealthStatus[barangay.key]
                          [healthStatus.key][monthlySummary.key] ??
                      barangay.value['total'];
                }
              }
            }
          }
        }
        // print(barangayHealthStatus);
        sliderMonths.sort(
          (a, b) => monthMap[a]! - monthMap[b]!,
        );
        if (!hasSliderInitialValue ||
            selectedHealthStatus.single != previousHealthStatus) {
          setState(() {
            sliderValue = sliderMonths.length - 1;
            previousHealthStatus = selectedHealthStatus.single;
          });
          hasSliderInitialValue = true;
        }
      },
      orElse: () {},
    );
    return ScaffoldPage(
        content: FractionallySizedBox(
      widthFactor: 0.97,
      heightFactor: 1,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 100),
              Column(
                children: [
                  const Text(
                    'Jones, Isabela Map',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  m3.SegmentedButton<HealthStatus>(
                    segments: segmentsWidget,
                    showSelectedIcon: false,
                    selected: selectedHealthStatus,
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        selectedHealthStatus = newSelection;
                      });
                    },
                  ),
                ],
              ),
              DatePicker(
                selected: selectedDate,
                onChanged: (value) {
                  setState(() {
                    selectedDate = value;
                    ref.read(currentDateSummaryStateProvider.notifier).state =
                        selectedDate!;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: MapWidget(
                    barangayData: barangayHealthStatus,
                    selectedHealthStatus: selectedHealthStatus.single,
                    selectedMonth: sliderMonths.isNotEmpty
                        ? sliderMonths[sliderValue]
                        : null,
                    callback: (barangay) {
                      setState(() {
                        selectedBarangay = barangay;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(sliderMonths.isNotEmpty
                          ? sliderMonths[sliderValue]
                          : '-'),
                      Slider(
                        max: sliderMonths.isEmpty
                            ? 0
                            : sliderMonths.length.toDouble() - 1,
                        min: 0,
                        value: sliderMonths.isNotEmpty
                            ? sliderValue.toDouble()
                            : 0,
                        onChanged: (value) {
                          setState(() {
                            sliderValue = value.floor();
                          });
                        },
                        divisions: sliderMonths.isEmpty
                            ? null
                            : sliderMonths.length - 1,
                        label: sliderMonths.isEmpty
                            ? null
                            : sliderMonths[sliderValue],
                      ),
                      Expanded(
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: Acrylic(
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              luminosityAlpha: 0.7,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        selectedBarangay,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22),
                                      ),
                                      Expanded(
                                        child: _barangayHealthStatusListView(
                                            selectedBarangay,
                                            barangayHealthStatus),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _barangayHealthStatusListView(
      String barangay, Map<String, dynamic> barangaysHealthStatus) {
    final List<ListTile> monthsListTile = [];
    final months = barangaysHealthStatus[barangay.toUpperCase()];

    // print(months);
    if (months != null) {
      final List<dynamic> monthsHealthStatus = months.entries
          .map(
            (e) => HealthStatusTile(
                month: e.key,
                mortality: e.value['MORTALITY'],
                morbidity: e.value['MORBIDITY'],
                natality: e.value['NATALITY']),
          )
          .toList();

      monthsHealthStatus.sort(
        (a, b) => monthMap[b.month]! - monthMap[a.month]!,
      );

      for (final monthHS in monthsHealthStatus) {
        final subtitle =
            "MORTALITY: ${monthHS.mortality ?? 0}   MORBIDITY: ${monthHS.morbidity ?? 0}   NATALITY: ${monthHS.natality ?? 0}";
        monthsListTile.add(ListTile(
          title: Text(monthHS.month),
          subtitle: Text(subtitle),
          onPressed: () {},
        ));
      }
      // for (final month in months.entries) {
      //   monthsListTile.add(ListTile(
      //     title: Text(month.key),
      //     subtitle: Text(month.value.toString()),
      //     onPressed: () {},
      //   ));
      // }
    }
    return ListView.builder(
      itemCount: monthsListTile.length,
      itemBuilder: (context, index) => monthsListTile[index],
    );
  }
}

class HealthStatusTile {
  final String month;
  final int? mortality;
  final int? morbidity;
  final int? natality;
  HealthStatusTile({
    required this.month,
    this.mortality,
    this.morbidity,
    this.natality,
  });
}
