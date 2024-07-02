import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/charts/model/health_status_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GenderStackedLineChart extends ConsumerStatefulWidget {
  const GenderStackedLineChart({super.key, required this.chartData});
  final List<HealthStatusChart> chartData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GenderStackedLineChartState();
}

class _GenderStackedLineChartState
    extends ConsumerState<GenderStackedLineChart> {
  TooltipBehavior? tooltipBehavior;
  @override
  void initState() {
    tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      // legend: const Legend(
      //     isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      title: const ChartTitle(
          text: "Gender Distribution",
          textStyle: TextStyle(fontWeight: FontWeight.bold)),
      series: [
        PieSeries<HealthStatusChart, String>(
          animationDuration: 800,
          dataSource: widget.chartData,
          xValueMapper: (datum, index) => datum.x,
          yValueMapper: (datum, index) => datum.y,
          dataLabelMapper: (datum, index) =>
              "${datum.y} ${datum.x == "M" ? "Males" : "Females"}",
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
          ),
          pointColorMapper: (datum, index) =>
              datum.x == "M" ? Colors.blue : Colors.red.dark,
        ),
      ],
      tooltipBehavior: tooltipBehavior,
    );
  }
}
