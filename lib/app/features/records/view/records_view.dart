import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/features/records/widgets/morbidity_widget.dart';
import 'package:health_sentry/app/features/records/widgets/mortality_widget.dart';
import 'package:health_sentry/app/features/records/widgets/natality_widget.dart';

class RecordsView extends ConsumerStatefulWidget {
  const RecordsView({super.key});
  static const routeName = '/records';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RecordsViewState();
}

class _RecordsViewState extends ConsumerState<RecordsView> {
  var currentPage = 0;
  late final List<NavigationPaneItem> items = [
    PaneItem(
        key: const ValueKey('morbidity'),
        icon: const SizedBox.shrink(),
        title: const Text('MORBIDITY'),
        body: const MorbidityWidget()),
    PaneItem(
        key: const ValueKey('natality'),
        icon: const SizedBox.shrink(),
        title: const Text('NATALITY'),
        body: const NatalityWidget()),
    PaneItem(
      key: const ValueKey('mortality'),
      icon: const SizedBox.shrink(),
      title: const Text('MORTALITY'),
      body: const MortalityWidget(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        header: const Text('Data Records'),
        selected: currentPage,
        onChanged: (i) => setState(() => currentPage = i),
        displayMode: PaneDisplayMode.top,
        items: items,
      ),
    );
  }
}
