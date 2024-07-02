import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/charts/model/health_status_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AgeDistributionHistogram extends ConsumerStatefulWidget {
  const AgeDistributionHistogram({super.key, required this.chartData});
  final List<HealthStatusChart> chartData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AgeDistributionHistogramState();
}

class _AgeDistributionHistogramState
    extends ConsumerState<AgeDistributionHistogram> {
  TooltipBehavior? tooltipBehavior;

  @override
  void initState() {
    tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: const ChartTitle(
          text: "Age Distribution",
          textStyle: TextStyle(fontWeight: FontWeight.bold)),
      tooltipBehavior: tooltipBehavior,
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
      ),
      series: _getHistogramSeries(),
      isTransposed: true,
    );
  }

  List<BarSeries<HealthStatusChart, String>> _getHistogramSeries() {
    return <BarSeries<HealthStatusChart, String>>[
      BarSeries<HealthStatusChart, String>(
        name: 'Age Group',
        dataSource: widget.chartData,
        sortingOrder: SortingOrder.ascending,

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
