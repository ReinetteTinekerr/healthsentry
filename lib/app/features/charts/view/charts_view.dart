import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m3;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/utils/enums.dart';
import 'package:health_sentry/app/core/widgets/health_status_button.dart';
import 'package:health_sentry/app/features/charts/local_data/months.dart';
import 'package:health_sentry/app/features/charts/model/health_status_chart.dart';
import 'package:health_sentry/app/features/charts/providers/summary_provider.dart';
import 'package:health_sentry/app/features/charts/widgets/age_distribution_histogram.dart';
import 'package:health_sentry/app/features/charts/widgets/cause_of_death_bar_chart.dart';
import 'package:health_sentry/app/features/charts/widgets/demographics_circular_chart.dart';
import 'package:health_sentry/app/features/charts/widgets/diseases_bar_chart.dart';
import 'package:health_sentry/app/features/charts/widgets/gender_stacked_line_chart.dart';
import 'package:health_sentry/app/features/charts/widgets/health_status_stacked_linechart.dart';

class ChartsView extends ConsumerStatefulWidget {
  const ChartsView({super.key});
  static const routeName = '/charts';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChartsViewState();
}

class _ChartsViewState extends ConsumerState<ChartsView> {
  DateTime? selectedDate;
  Set<HealthStatus> selectedHealthStatus = {HealthStatus.morbidity};

  @override
  void initState() {
    selectedDate = ref.read(currentDateSummaryStateProvider.notifier).state;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final healthStatusSummary = ref.watch(healthStatusSummaryFutureProvider);

    final Map<String, int> ageDistributionSummary = {};
    final Map<String, int> genderDistributionSummary = {};
    final Map<String, int> diseaseDistributionSummary = {};
    final Map<String, int> causeOfDeathDistributionSummary = {};

    List<HealthStatusChart> diseaseDistributionChartData = [];
    List<HealthStatusChart> causeOfDeathDistributionChartData = [];
    List<HealthStatusChart> genderDistributionChartData = [];
    List<HealthStatusChart> ageDistributionChartData = [];
    healthStatusSummary.maybeWhen(
      data: (data) {
        final summaryData = data.data();
        if (summaryData != null) {
          for (final healthStatus in summaryData.entries) {
            for (final monthlySummary in healthStatus.value.entries) {
              var currentHealthStatus =
                  selectedHealthStatus.single.name.toString().toUpperCase();
              // print("${monthlySummary.key} ${monthlySummary.value}");
              // if (currentHealthStatus == monthlySummary.key) {
              for (final barangays in monthlySummary.value.entries) {
                if (barangays.value is Map<String, dynamic>) {
                  for (final barangay in barangays.value.entries) {
                    if (selectedHealthStatus.single != HealthStatus.natality &&
                        monthlySummary.key != 'NATALITY') {
                      for (final disease in barangay.value.entries) {
                        if (disease.value is Map<String, dynamic>) {
                          for (final ageGroup in disease.value.entries) {
                            for (final gender in ageGroup.value.entries) {
                              if (monthlySummary.key == 'MORBIDITY') {
                                diseaseDistributionSummary.update(
                                  disease.key,
                                  (value) => value + (gender.value as int),
                                  ifAbsent: () => 1,
                                );
                              } else if (monthlySummary.key == "MORTALITY") {
                                causeOfDeathDistributionSummary.update(
                                  disease.key,
                                  (value) => value + (gender.value as int),
                                  ifAbsent: () => 1,
                                );
                              }
                              if (currentHealthStatus == monthlySummary.key) {
                                if (gender.value > 0) {
                                  ageDistributionSummary.update(
                                    ageGroup.key,
                                    (value) => value + (gender.value as int),
                                    ifAbsent: () => gender.value,
                                  );
                                }
                                genderDistributionSummary.update(
                                  gender.key,
                                  (value) => value + (gender.value as int),
                                  ifAbsent: () => gender.value,
                                );
                              }
                            }
                          }
                        }
                      }
                    } else if (selectedHealthStatus.single ==
                            HealthStatus.natality &&
                        monthlySummary.key == 'NATALITY') {
                      for (final ageGroup in barangay.value.entries) {
                        if (ageGroup.value is Map<String, dynamic>) {
                          for (final gender in ageGroup.value.entries) {
                            ageDistributionSummary.update(
                              ageGroup.key,
                              (value) => value + (gender.value as int),
                              ifAbsent: () => gender.value,
                            );

                            genderDistributionSummary.update(
                              gender.key,
                              (value) => value + (gender.value as int),
                              ifAbsent: () => 1,
                            );
                          }
                        }
                      }
                    }
                  }
                }
              }
              // }
            }
          }
        }

        diseaseDistributionChartData = diseaseDistributionSummary.entries
            .map((e) => HealthStatusChart(x: e.key, y: e.value))
            .toList();
        diseaseDistributionChartData.sort((a, b) => b.y.compareTo(a.y));
        diseaseDistributionChartData =
            diseaseDistributionChartData.take(10).toList();
        causeOfDeathDistributionChartData = causeOfDeathDistributionSummary
            .entries
            .map((e) => HealthStatusChart(x: e.key, y: e.value))
            .toList();
        causeOfDeathDistributionChartData.sort((a, b) => b.y.compareTo(a.y));
        causeOfDeathDistributionChartData =
            causeOfDeathDistributionChartData.take(10).toList();
        ageDistributionChartData = ageDistributionSummary.entries
            .map((e) => HealthStatusChart(x: e.key, y: e.value))
            .toList();
        genderDistributionChartData = genderDistributionSummary.entries
            .map(
              (e) => HealthStatusChart(x: e.key, y: e.value),
            )
            .toList();
      },
      orElse: () {},
    );

    return ScaffoldPage.scrollable(
      children: [
        Wrap(
          alignment: WrapAlignment.end,
          children: [
            DatePicker(
              selected: selectedDate,
              onChanged: (value) {
                setState(() {
                  selectedDate = value;
                  ref.read(currentDateSummaryStateProvider.notifier).state =
                      value;
                });
              },
            )
          ],
        ),
        const SizedBox(height: 32),
        m3.Wrap(
          alignment: WrapAlignment.center,
          children: [
            m3.SegmentedButton<HealthStatus>(
              segments: segmentsWidget,
              showSelectedIcon: false,
              selected: selectedHealthStatus,
              onSelectionChanged: (newSelection) {
                setState(() {
                  selectedHealthStatus = newSelection;
                });
              },
            )
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
                width: 500,
                height: 400,
                child: healthStatusSummary.maybeWhen(
                  data: (data) {
                    final summaryData = data.data();
                    final List<HealthStatusChart> mortalityChartData = [];
                    final List<HealthStatusChart> morbidityChartData = [];
                    final List<HealthStatusChart> natalityChartData = [];
                    if (summaryData != null) {
                      for (final monthlySummary in summaryData.entries) {
                        for (final healthStatus
                            in monthlySummary.value.entries) {
                          if (healthStatus.key == 'MORTALITY') {
                            mortalityChartData.add(HealthStatusChart(
                                x: monthlySummary.key,
                                y: healthStatus.value['total']));
                          } else if (healthStatus.key == 'MORBIDITY') {
                            morbidityChartData.add(HealthStatusChart(
                                x: monthlySummary.key,
                                y: healthStatus.value['total']));
                          } else if (healthStatus.key == 'NATALITY') {
                            natalityChartData.add(HealthStatusChart(
                                x: monthlySummary.key,
                                y: healthStatus.value['total']));
                          }
                        }
                      }
                    }
                    mortalityChartData
                        .sort((a, b) => monthMap[a.x]! - monthMap[b.x]!);
                    morbidityChartData
                        .sort((a, b) => monthMap[a.x]! - monthMap[b.x]!);
                    natalityChartData
                        .sort((a, b) => monthMap[a.x]! - monthMap[b.x]!);
                    return HealthstatusStackedLineChart(
                        mortalityChartData: mortalityChartData,
                        morbidityChartData: morbidityChartData,
                        natalityChartData: natalityChartData);
                  },
                  orElse: () {
                    return Container();
                  },
                )),
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 500,
              height: 500,
              child: healthStatusSummary.maybeWhen(
                data: (data) {
                  final summaryData = data.data();
                  final Map<String, int> demographicsSummary = {};
                  if (summaryData != null) {
                    for (final healthStatus in summaryData.entries) {
                      for (final monthlySummary in healthStatus.value.entries) {
                        if (selectedHealthStatus.single.name
                                .toString()
                                .toUpperCase() ==
                            monthlySummary.key) {
                          for (final barangays
                              in monthlySummary.value.entries) {
                            if (barangays.value is Map<String, dynamic>) {
                              for (final barangay in barangays.value.entries) {
                                final total = barangay.value['total'] as int;
                                demographicsSummary[barangay.key] =
                                    demographicsSummary[barangay.key] ??
                                        0 + total;
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  final List<HealthStatusChart> chartData =
                      demographicsSummary.entries
                          .map(
                            (e) => HealthStatusChart(x: e.key, y: e.value),
                          )
                          .toList();
                  return DemographicsCircularChart(chartData: chartData);
                },
                orElse: () => Container(),
              ),
            ),
            SizedBox(
              width: 500,
              height: 500,
              child: AgeDistributionHistogram(
                chartData: ageDistributionChartData,
              ),
            )
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: 500,
              height: 400,
              child: GenderStackedLineChart(
                chartData: genderDistributionChartData,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 500,
              height: 500,
              child: DiseasesBarChart(chartData: diseaseDistributionChartData),
            ),
            SizedBox(
              width: 500,
              height: 500,
              child: CauseOfDeathBarChart(
                  chartData: causeOfDeathDistributionChartData),
            )
          ],
        ),
      ],
    );
  }
}
