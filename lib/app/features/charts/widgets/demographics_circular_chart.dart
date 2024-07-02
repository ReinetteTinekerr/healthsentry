import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/charts/model/health_status_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DemographicsCircularChart extends ConsumerStatefulWidget {
  const DemographicsCircularChart({super.key, required this.chartData});
  final List<HealthStatusChart> chartData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DemographicsCircularChartState();
}

class _DemographicsCircularChartState
    extends ConsumerState<DemographicsCircularChart> {
  late TooltipBehavior tooltip;

  @override
  void initState() {
    tooltip = TooltipBehavior(enable: true, format: 'point.x : point.y');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: const ChartTitle(
          text: "Demographics",
          textStyle: TextStyle(fontWeight: FontWeight.bold)),
      legend: const Legend(
          isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      tooltipBehavior: tooltip,
      series: _getDefaultDoughnutSeries(),
    );
  }

  /// Returns the doughnut series which need to be render.
  List<DoughnutSeries<HealthStatusChart, String>> _getDefaultDoughnutSeries() {
    return <DoughnutSeries<HealthStatusChart, String>>[
      DoughnutSeries<HealthStatusChart, String>(
        radius: '80%',
        explode: true,
        explodeOffset: '10%',
        dataSource: widget.chartData,
        xValueMapper: (HealthStatusChart data, _) => data.x,
        yValueMapper: (HealthStatusChart data, _) => data.y,
        // dataLabelMapper: (HealthStatusChart data, _) => data.text,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      )
    ];
  }
}
