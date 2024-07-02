import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/utils/functions.dart';
import 'package:health_sentry/app/features/settings/model/health_status_settings.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  int mortalityTeal = 0;
  int mortalityYellowGreen = 0;
  int mortalityOrange = 0;
  int mortalityRed = 0;
  int morbidityTeal = 0;
  int morbidityYellowGreen = 0;
  int morbidityOrange = 0;
  int morbidityRed = 0;
  int natalityTeal = 0;
  int natalityYellowGreen = 0;
  int natalityOrange = 0;
  int natalityRed = 0;
  @override
  void initState() {
    readSettingsData('settings.json').then(
      (value) {
        setState(() {
          mortalityTeal = value.mortalityTeal;
          mortalityYellowGreen = value.mortalityYellowGreen;
          mortalityOrange = value.mortalityOrange;
          mortalityRed = value.mortalityRed;
          morbidityTeal = value.morbidityTeal;
          morbidityYellowGreen = value.morbidityYellowGreen;
          morbidityOrange = value.morbidityOrange;
          morbidityRed = value.morbidityRed;
          natalityTeal = value.natalityTeal;
          natalityYellowGreen = value.natalityYellowGreen;
          natalityOrange = value.natalityOrange;
          natalityRed = value.natalityRed;
        });
      },
    ).onError(
      (error, stackTrace) {
        debugPrint('error no such file');
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        content: FractionallySizedBox(
      widthFactor: 0.95,
      heightFactor: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            "Monthly barangay health status configuration",
          ),
          const Tooltip(
            message:
                "teal=healthy yellow-green=caution orange=severe red=critical",
            child: Text(
              "Mortality",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.teal.light,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: mortalityTeal,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      mortalityTeal = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: mortalityOrange,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      mortalityOrange = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 222, 231, 102),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: mortalityYellowGreen,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      mortalityYellowGreen = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: mortalityRed,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      mortalityRed = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Tooltip(
            message:
                "teal=healthy yellow-green=caution orange=severe red=critical",
            child: Text(
              "Morbidity",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.teal.light,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: morbidityTeal,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      morbidityTeal = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: morbidityOrange,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      morbidityOrange = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 222, 231, 102),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: morbidityYellowGreen,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      morbidityYellowGreen = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: morbidityRed,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      morbidityRed = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Tooltip(
            message:
                "teal=healthy yellow-green=caution orange=severe red=critical",
            child: Text(
              "Natality",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.teal.light,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: natalityTeal,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      natalityTeal = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: natalityOrange,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      natalityOrange = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 222, 231, 102),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: natalityYellowGreen,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      natalityYellowGreen = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: SizedBox.square(
                  dimension: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: NumberBox(
                  value: natalityRed,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      natalityRed = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          FilledButton(
              child: const Text('Save'),
              onPressed: () {
                writeSettingsDataToFile(
                        HealthStatusSettings(
                            mortalityTeal: mortalityTeal,
                            mortalityYellowGreen: mortalityYellowGreen,
                            mortalityOrange: mortalityOrange,
                            mortalityRed: mortalityRed,
                            morbidityTeal: morbidityTeal,
                            morbidityYellowGreen: morbidityYellowGreen,
                            morbidityOrange: morbidityOrange,
                            morbidityRed: morbidityRed,
                            natalityTeal: natalityTeal,
                            natalityYellowGreen: natalityYellowGreen,
                            natalityOrange: natalityOrange,
                            natalityRed: natalityRed),
                        'settings.json')
                    .then(
                  (value) {},
                );
              })
        ],
      ),
    ));
  }
}
