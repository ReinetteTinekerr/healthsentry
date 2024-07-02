import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/local_storage/local_data.dart';
import 'package:health_sentry/app/core/utils/enums.dart';
import 'package:health_sentry/app/core/utils/functions.dart';
import 'package:health_sentry/app/features/settings/model/health_status_settings.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:flutter/material.dart' as mat;

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget(
      {super.key,
      required this.barangayData,
      required this.selectedHealthStatus,
      required this.selectedMonth,
      required this.callback});
  final Map<String, dynamic> barangayData;
  final HealthStatus selectedHealthStatus;
  final String? selectedMonth;
  final void Function(String barangay) callback;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  late MapZoomPanBehavior zoomPanBehavior;
  late MapShapeSource mapSource;
  late List<MapColorMapper> colorMappers;
  late HealthStatusSettings settings;
  int selectedIndex = -1;

  @override
  void initState() {
    readSettingsData('settings.json').then(
      (value) {
        settings = value;
      },
    ).onError(
      (error, stackTrace) {
        settings = HealthStatusSettings.sample();
      },
    );

    zoomPanBehavior = MapZoomPanBehavior();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mapSource = MapShapeSource.asset(
      'assets/jones.json',
      shapeDataField: 'name',
      dataCount: LocalData.barangays.length,
      primaryValueMapper: (index) => LocalData.barangays[index],
      dataLabelMapper: (int index) => LocalData.barangays[index],
      // shapeColorMappers: colorMappers,
      shapeColorValueMapper: (index) {
        final barangay = LocalData.barangays[index].toUpperCase();

        if (widget.barangayData[barangay] != null &&
            widget.barangayData[barangay][widget.selectedMonth] != null &&
            widget.barangayData[barangay][widget.selectedMonth]
                    [widget.selectedHealthStatus.name.toUpperCase()] !=
                null) {
          final value = widget.barangayData[barangay][widget.selectedMonth]
              [widget.selectedHealthStatus.name.toUpperCase()];
          switch (widget.selectedHealthStatus) {
            case HealthStatus.mortality:
              if (value <= settings.mortalityTeal) {
                return Colors.green;
              } else if (value <= settings.mortalityYellowGreen) {
                return const Color.fromARGB(255, 222, 231, 102);
              } else if (value <= settings.mortalityOrange) {
                return Colors.orange;
              } else if (value >= settings.mortalityRed) {
                return Colors.red;
              }
            case HealthStatus.morbidity:
              if (value <= settings.morbidityTeal) {
                return Colors.green;
              } else if (value <= settings.morbidityYellowGreen) {
                return const Color.fromARGB(255, 222, 231, 102);
              } else if (value <= settings.morbidityOrange) {
                return Colors.orange;
              } else if (value >= settings.morbidityRed) {
                return Colors.red;
              }
            case HealthStatus.natality:
              if (value <= settings.natalityTeal) {
                return Colors.green;
              } else if (value <= settings.natalityYellowGreen) {
                return const Color.fromARGB(255, 222, 231, 102);
              } else if (value <= settings.natalityOrange) {
                return Colors.orange;
              } else if (value >= settings.natalityRed) {
                return Colors.red;
              }
          }
        } else {
          return Colors.grey.toAccentColor().light;
        }
      },
    );
    return SfMaps(layers: [
      MapShapeLayer(
        source: mapSource,
        // color: Colors.grey.toAccentColor().lightest,
        strokeColor: const Color.fromRGBO(255, 255, 255, 1),
        showDataLabels: true,
        shapeTooltipBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text('Barangay: ${LocalData.barangays[index]}'),
        ),
        tooltipSettings: const MapTooltipSettings(
          color: Color.fromRGBO(255, 255, 255, 1),
          strokeColor: Color.fromRGBO(153, 153, 153, 1),
          strokeWidth: 0.5,
          hideDelay: 3.0,
        ),
        dataLabelSettings: const MapDataLabelSettings(
            textStyle: TextStyle(color: Colors.white)),
        loadingBuilder: (context) => const ProgressBar(),
        zoomPanBehavior: zoomPanBehavior,
        selectionSettings: const MapSelectionSettings(
            color: Color.fromARGB(255, 147, 146, 144),
            strokeColor: Colors.white,
            strokeWidth: 2),
        // legend: const MapLegend.bar(
        //   MapElement.shape,
        //   segmentSize: Size(25, 12),
        //   position: MapLegendPosition.bottom,
        //   padding: EdgeInsets.only(bottom: 30),
        //   spacing: 0.0,
        //   textStyle: TextStyle(fontSize: 10),
        //   showPointerOnHover: true,
        // ),
        onSelectionChanged: (index) {
          if (index != selectedIndex) {
            debugPrint(LocalData.barangays[index]);
            widget.callback(LocalData.barangays[index]);
          }
        },
      )
    ]);
  }
}
