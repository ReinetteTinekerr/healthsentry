import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/charts/model/health_status_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HealthstatusStackedLineChart extends ConsumerStatefulWidget {
  const HealthstatusStackedLineChart(
      {super.key,
      required this.mortalityChartData,
      required this.morbidityChartData,
      required this.natalityChartData});
  final List<HealthStatusChart> mortalityChartData;
  final List<HealthStatusChart> morbidityChartData;
  final List<HealthStatusChart> natalityChartData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HealthstatusstackedlinechartState();
}

class _HealthstatusstackedlinechartState
    extends ConsumerState<HealthstatusStackedLineChart> {
  TrackballBehavior? trackballBehavior;

  @override
  void initState() {
    trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: const ChartTitle(
        text: "Mortality, Morbidity, Natality",
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      legend: const Legend(isVisible: true),
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        labelRotation: 0,
      ),
      primaryYAxis: const NumericAxis(
        axisLine: AxisLine(width: 0),
        labelFormat: '{value}',
        majorTickLines: MajorTickLines(size: 0),
      ),
      trackballBehavior: trackballBehavior,
      series: _getStackedLineSeries(),
    );
  }

  List<LineSeries<HealthStatusChart, String>> _getStackedLineSeries() {
    return <LineSeries<HealthStatusChart, String>>[
      LineSeries<HealthStatusChart, String>(
          dataSource: widget.mortalityChartData,
          xValueMapper: (HealthStatusChart status, _) => status.x,
          yValueMapper: (HealthStatusChart status, _) => status.y,
          name: 'Mortality',
          color: Colors.red,
          markerSettings: const MarkerSettings(isVisible: true)),
      LineSeries<HealthStatusChart, String>(
          dataSource: widget.morbidityChartData,
          xValueMapper: (HealthStatusChart status, _) => status.x,
          yValueMapper: (HealthStatusChart status, _) => status.y,
          name: 'Morbidity',
          color: Colors.purple,
          markerSettings: const MarkerSettings(isVisible: true)),
      LineSeries<HealthStatusChart, String>(
          dataSource: widget.natalityChartData,
          xValueMapper: (HealthStatusChart status, _) => status.x,
          yValueMapper: (HealthStatusChart status, _) => status.y,
          name: 'Natality',
          color: Colors.blue,
          markerSettings: const MarkerSettings(isVisible: true)),
    ];
  }
}
