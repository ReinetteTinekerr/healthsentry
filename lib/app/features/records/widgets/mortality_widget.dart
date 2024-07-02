import 'package:data_table_2/data_table_2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/local_storage/local_data.dart';
import 'package:health_sentry/app/core/utils/date_format.dart';
import 'package:health_sentry/app/core/utils/functions.dart';
import 'package:health_sentry/app/core/utils/validator.dart';
import 'package:health_sentry/app/features/accounts/model/user.dart';
import 'package:health_sentry/app/features/accounts/providers/accounts_provider.dart';
import 'package:health_sentry/app/features/records/model/mortality.dart';
import 'package:health_sentry/app/features/records/providers/mortalities_provider.dart';
import 'package:health_sentry/app/features/records/providers/records_provider.dart';
import 'package:health_sentry/app/features/records/repository/records_repository.dart';
import 'package:health_sentry/app/features/records/widgets/commandbar_widget.dart';
import 'package:flutter/material.dart' as material;

class MortalityWidget extends ConsumerStatefulWidget {
  const MortalityWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MortalityWidgetState();
}

class _MortalityWidgetState extends ConsumerState<MortalityWidget> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mortalitiesStream = ref.watch(mortalitiesStreamProvider);
    final currentUserFuture = ref.watch(currentUserFutureProvider);

    return ScaffoldPage(
      padding: const EdgeInsets.symmetric(vertical: 8),
      header: PageHeader(
        commandBar: CommandBarWidget(
          newContentDialog: () {
            currentUserFuture.maybeWhen(
              data: (data) {
                if (data == null) return;
                newMortalityContentDialog(
                  context,
                  userBarangay: data.barangay,
                  callback: (mortality) {
                    mortality = mortality.copyWith(
                        userId: data.userId, submittedBy: data.username);
                    ref
                        .read(recordsProvider)
                        .addNewMortality(mortality)
                        .then((value) {});

                    ref
                        .read(recordsProvider)
                        .updateSummary(
                          dataRecord: mortality,
                        )
                        .then(
                          (value) {},
                        );
                  },
                );
              },
              orElse: () {},
            );
          },
          exportData: () async {
            mortalitiesStream.maybeWhen(
              data: (data) async {
                final mortalities = data.docs.map((e) => e.data()).toList();

                final selectedDate = ref.read(currentDateMortalitiesProvider);
                exportToExcel(dataRecord: mortalities, date: selectedDate).then(
                  (value) async {
                    if (value.isEmpty) return;
                    await fileSavedInfoBar(context, value);
                  },
                );
              },
              orElse: () {},
            );
          },
        ),
      ),
      content: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: Wrap(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 250,
                  child: DatePicker(
                    selected: selectedDate,
                    onChanged: (newDate) {
                      selectedDate = newDate;
                      ref.read(currentDateMortalitiesProvider.notifier).state =
                          newDate;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 550,
                width: double.infinity,
                child: mortalitiesStream.when(
                  data: (data) {
                    final mortalities = data.docs.map((e) {
                      return (e.id, e.data());
                    }).toList();
                    return PaginatedDataTableWidget(
                      data: mortalities,
                      callback: (mortality) async {
                        currentUserFuture.maybeWhen(
                          data: (data) {
                            showMortalityContentDialog(
                              context,
                              mortalityWithDocId: mortality,
                              user: data,
                              deleteCallback: (documentId) {
                                ref.read(recordsProvider).deleteRecord(
                                    collection: Mortality.mortalityString,
                                    documentId: documentId);

                                ref
                                    .read(recordsProvider)
                                    .updateSummary(
                                      dataRecord: mortality.$2,
                                      type: SummaryType.decrement,
                                    )
                                    .then(
                                      (value) {},
                                    );
                              },
                            );
                          },
                          orElse: () {},
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return Stack(
                      children: [
                        PaginatedDataTableWidget(
                          data: const [],
                          callback: (_) {},
                        ),
                        Center(
                          child: InfoBar(
                            title: const Text('Something went wrong :/'),
                            content: const Text(''),
                            action: IconButton(
                              icon: const Icon(FluentIcons.clear),
                              onPressed: () {
                                ref
                                    .read(
                                        currentDateMortalitiesProvider.notifier)
                                    .state = DateTime.now();
                              },
                            ),
                            severity: InfoBarSeverity.error,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.1,
                      child: ProgressBar(),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void newMortalityContentDialog(BuildContext context,
      {required String userBarangay,
      required void Function(Mortality mortality) callback}) async {
    var selectedDate = DateTime.now();
    var selectedAgeGroup = LocalData.diseaseAgeGroup.entries.first.value;
    var selectedGender = LocalData.genders.values.first;
    var selectedBarangay = userBarangay.toUpperCase();
    final mortalityDiseases = [];
    mortalityDiseases.addAll(LocalData.mortalityDisease);
    mortalityDiseases.addAll(LocalData.diseases);
    var selectedDisease = mortalityDiseases.first;
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('New Mortality'),
        content: StatefulBuilder(
          builder: (context, StateSetter setState) {
            return SingleChildScrollView(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DatePicker(
                      header: 'Select date',
                      selected: selectedDate,
                      onChanged: (date) {
                        setState(
                          () => selectedDate = date,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: 'Cause of Death',
                      child: AutoSuggestBox<String>(
                        placeholder: selectedDisease.toUpperCase(),
                        onChanged: (text, reason) {
                          setState(
                            () => selectedDisease = text.toUpperCase(),
                          );
                        },
                        onSelected: (barangay) =>
                            setState(() => selectedDisease = barangay.value!),
                        items: mortalityDiseases.map(
                          (barangay) {
                            return AutoSuggestBoxItem<String>(
                              value: barangay,
                              label: barangay.toUpperCase(),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: "Age",
                      child: ComboBox(
                        value: selectedAgeGroup,
                        items: LocalData.diseaseAgeGroup.entries.map(
                          (e) {
                            return ComboBoxItem(
                              value: e.value,
                              child: Text(e.key.toUpperCase()),
                            );
                          },
                        ).toList(),
                        onChanged: (value) => setState(
                          () => selectedAgeGroup = value!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: 'Gender',
                      child: ComboBox(
                        value: selectedGender,
                        items: LocalData.genders.entries.map(
                          (e) {
                            return ComboBoxItem(
                              value: e.value.toUpperCase(),
                              child: Text(e.key.toUpperCase()),
                            );
                          },
                        ).toList(),
                        onChanged: (value) => setState(
                          () => selectedGender = value!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: 'Barangay',
                      child: AutoSuggestBox<String>(
                        placeholder: selectedBarangay.toUpperCase(),
                        onSelected: (barangay) =>
                            setState(() => selectedBarangay = barangay.value!),
                        items: LocalData.barangays.map(
                          (barangay) {
                            return AutoSuggestBoxItem<String>(
                              value: barangay,
                              label: barangay.toUpperCase(),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, 'cancel');
              // Delete file here
            },
          ),
          FilledButton(
            child: const Text('Submit'),
            onPressed: () {
              callback(Mortality(
                  userId: '',
                  timestamp: DateTime.now(),
                  date: selectedDate,
                  gender: selectedGender,
                  barangay: selectedBarangay,
                  diseaseAgeGroup: selectedAgeGroup,
                  causeOfDeath: selectedDisease,
                  submittedBy: ""));
              Navigator.pop(context, 'Done');
            },
          ),
        ],
      ),
    );
    setState(() {});
  }

  void showMortalityContentDialog(BuildContext context,
      {required (String, Mortality) mortalityWithDocId,
      required User? user,
      required void Function(String documentId) deleteCallback}) async {
    final docId = mortalityWithDocId.$1;
    final mortality = mortalityWithDocId.$2;
    final userId = user!.userId;
    final hasPermission = hasDeletePermission(
        docUserId: mortality.userId, currentUserId: userId, role: user.role);

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mortality'),
            Text(
              timestampFormat.format(mortality.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: "Date",
                child: TextBox(
                  placeholder: dateFormat.format(mortality.date),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Cause of Death",
                child: TextBox(
                  minLines: 1,
                  maxLines: 3,
                  placeholder: mortality.causeOfDeath,
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Age",
                child: TextBox(
                  placeholder: LocalData.findDiseaseAgeGroupKey(
                      mortality.diseaseAgeGroup),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Gender",
                child: TextBox(
                  placeholder: LocalData.findGenderKey(mortality.gender),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Barangay",
                child: TextBox(
                  placeholder: mortality.barangay.toUpperCase(),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Submitted by",
                child: TextBox(
                  placeholder: mortality.submittedBy.toUpperCase(),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            onPressed: !hasPermission
                ? null
                : () {
                    deleteCallback(docId);
                    Navigator.pop(context, 'delete');
                    // Delete file here
                  },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context, 'close');
            },
          ),
        ],
      ),
    );
    setState(() {});
  }
}

class PaginatedDataTableWidget extends StatelessWidget {
  const PaginatedDataTableWidget(
      {super.key, required this.data, required this.callback});

  final List<(String, Mortality)> data;
  final void Function((String, Mortality) mortality) callback;

  @override
  Widget build(BuildContext context) {
    return material.Material(
      child: PaginatedDataTable2(
        headingRowColor: WidgetStateProperty.all(Colors.black),
        headingTextStyle: const TextStyle(color: Colors.white),
        columns: const [
          DataColumn2(
            label: Text('Timestamp'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Date'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Cause of Death'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Age'),
          ),
          DataColumn2(
            label: Text('Gender'),
          ),
          DataColumn2(
            label: Text('Barangay'),
          ),
          DataColumn2(
            label: Text('Submitted by'),
          ),
        ],
        source: MorbidityDataSource(data: data, callback: callback),
      ),
    );
  }
}

class MorbidityDataSource extends material.DataTableSource {
  final List<(String, Mortality)> data;
  final void Function((String, Mortality) mortality) callback;

  MorbidityDataSource({required this.data, required this.callback});

  @override
  material.DataRow? getRow(int index) {
    if (index > data.length || index < 0) return null;

    final mortalityWithDocId = data[index];
    final mortality = mortalityWithDocId.$2;
    return DataRow2(
        onTap: () {
          callback(mortalityWithDocId);
        },
        cells: [
          material.DataCell(Text(
            timestampFormat.format(mortality.timestamp),
            style: const TextStyle(fontSize: 12),
          )),
          material.DataCell(Text(dateFormat.format(mortality.date))),
          material.DataCell(Text(
            mortality.causeOfDeath,
            style: const TextStyle(fontSize: 11, overflow: TextOverflow.fade),
          )),
          material.DataCell(Text(
              LocalData.findDiseaseAgeGroupKey(mortality.diseaseAgeGroup))),
          material.DataCell(Text(mortality.gender)),
          material.DataCell(Text(mortality.barangay.toUpperCase())),
          material.DataCell(Text(mortality.submittedBy.toUpperCase())),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
