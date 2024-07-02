import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/charts/model/health_status_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CauseOfDeathBarChart extends ConsumerStatefulWidget {
  const CauseOfDeathBarChart({super.key, required this.chartData});

  final List<HealthStatusChart> chartData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CauseOfDeathBarChartState();
}

class _CauseOfDeathBarChartState extends ConsumerState<CauseOfDeathBarChart> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: const ChartTitle(
          text: "Top 10 Cause of Death",
          textStyle: TextStyle(fontWeight: FontWeight.bold)),
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
      ),
      series: _getBarSeries(),
    );
  }

  List<BarSeries<HealthStatusChart, String>> _getBarSeries() {
    return <BarSeries<HealthStatusChart, String>>[
      BarSeries<HealthStatusChart, String>(
        name: 'Cause of Death',
        dataSource: widget.chartData,
        sortingOrder: SortingOrder.ascending,

        color: Colors.red,

        /// It used to add the dashes line for distribution line.
        xValueMapper: (HealthStatusChart status, _) => status.x,
        yValueMapper: (HealthStatusChart status, _) => status.y,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      )
    ];
  }
}
