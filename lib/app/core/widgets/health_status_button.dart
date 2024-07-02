import 'package:fluent_ui/fluent_ui.dart';
import 'package:health_sentry/app/core/utils/enums.dart';
import 'package:flutter/material.dart' as m3;

final List<m3.ButtonSegment<HealthStatus>> segmentsWidget = [
  const m3.ButtonSegment(
      value: HealthStatus.mortality, label: Text("Mortality")),
  const m3.ButtonSegment(
      value: HealthStatus.morbidity, label: Text("Morbidity")),
  const m3.ButtonSegment(value: HealthStatus.natality, label: Text("Natality")),
];
