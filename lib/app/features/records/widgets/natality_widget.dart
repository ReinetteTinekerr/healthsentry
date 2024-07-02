import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/local_storage/local_data.dart';
import 'package:health_sentry/app/core/utils/date_format.dart';
import 'package:health_sentry/app/core/utils/functions.dart';
import 'package:health_sentry/app/core/utils/validator.dart';
import 'package:health_sentry/app/features/accounts/model/user.dart';
import 'package:health_sentry/app/features/accounts/providers/accounts_provider.dart';
import 'package:health_sentry/app/features/records/model/natality.dart';
import 'package:health_sentry/app/features/records/providers/mortalities_provider.dart';
import 'package:health_sentry/app/features/records/providers/natalities_provider.dart';
import 'package:health_sentry/app/features/records/providers/records_provider.dart';
import 'package:health_sentry/app/features/records/repository/records_repository.dart';
import 'package:health_sentry/app/features/records/widgets/commandbar_widget.dart';
import 'package:data_table_2/data_table_2.dart';

class NatalityWidget extends ConsumerStatefulWidget {
  const NatalityWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NatalityWidgetState();
}

class _NatalityWidgetState extends ConsumerState<NatalityWidget> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final natalitiesStream = ref.watch(natalitiesStreamProvider);
    final currentUserFuture = ref.watch(currentUserFutureProvider);

    return ScaffoldPage(
      padding: const EdgeInsets.symmetric(vertical: 8),
      header: PageHeader(
        commandBar: CommandBarWidget(
          newContentDialog: () {
            currentUserFuture.maybeWhen(
              data: (data) {
                if (data == null) return;
                showNewNatalityContentDialog(
                  context,
                  userBarangay: data.barangay,
                  callback: (natality) async {
                    natality = natality.copyWith(
                        userId: data.userId, submittedBy: data.username);
                    ref
                        .read(recordsProvider)
                        .addNewNatality(natality)
                        .then((value) {});
                    ref
                        .read(recordsProvider)
                        .updateSummary(
                          dataRecord: natality,
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
            natalitiesStream.maybeWhen(
              data: (data) {
                final natalities = data.docs.map((e) => e.data()).toList();

                final selectedDate = ref.read(currentDateMortalitiesProvider);
                exportToExcel(dataRecord: natalities, date: selectedDate).then(
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
          widthFactor: 0.80,
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
                      ref.read(currentDateNatalitiesProvider.notifier).state =
                          newDate;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 550,
                width: double.infinity,
                child: natalitiesStream.when(
                  data: (data) {
                    final natalities = data.docs.map((e) {
                      return (e.id, e.data());
                    }).toList();
                    return PaginatedDataTableWidget(
                      data: natalities,
                      callback: (natality) {
                        currentUserFuture.maybeWhen(
                          data: (data) {
                            showNatalityContentDialog(context,
                                natalityWithDocId: natality,
                                user: data, deleteCallback: (documentId) {
                              ref.read(recordsProvider).deleteRecord(
                                  collection: Natality.natalityString,
                                  documentId: documentId);

                              ref
                                  .read(recordsProvider)
                                  .updateSummary(
                                    dataRecord: natality.$2,
                                    type: SummaryType.decrement,
                                  )
                                  .then(
                                    (value) {},
                                  );
                            });
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
                                        currentDateNatalitiesProvider.notifier)
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

  void showNewNatalityContentDialog(BuildContext context,
      {required String userBarangay,
      required void Function(Natality natality) callback}) async {
    var selectedDate = DateTime.now();
    var selectedGender = LocalData.genders.values.first;
    var selectedBarangay = userBarangay;
    var selectedMotherAgeGroup = LocalData.parentsAgeGroup.entries.first.value;
    var selectedFatherAgeGroup = LocalData.parentsAgeGroup.entries.first.value;
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('New Natality'),
        content: StatefulBuilder(
          builder: (context, StateSetter setState) {
            return SingleChildScrollView(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DatePicker(
                      header: 'Birthdate',
                      selected: selectedDate,
                      onChanged: (date) {
                        setState(
                          () => selectedDate = date,
                        );
                      },
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
                    InfoLabel(
                      label: "Mother's age",
                      child: ComboBox(
                        value: selectedMotherAgeGroup,
                        items: LocalData.parentsAgeGroup.entries.map(
                          (e) {
                            return ComboBoxItem(
                              value: e.value,
                              child: Text(e.key.toUpperCase()),
                            );
                          },
                        ).toList(),
                        onChanged: (value) => setState(
                          () => selectedMotherAgeGroup = value!,
                        ),
                      ),
                    ),
                    InfoLabel(
                      label: "Father's age",
                      child: ComboBox(
                        value: selectedFatherAgeGroup,
                        items: LocalData.parentsAgeGroup.entries.map(
                          (e) {
                            return ComboBoxItem(
                              value: e.value,
                              child: Text(e.key.toUpperCase()),
                            );
                          },
                        ).toList(),
                        onChanged: (value) => setState(
                          () => selectedFatherAgeGroup = value!,
                        ),
                      ),
                    ),
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
              callback(
                Natality(
                    userId: "",
                    timestamp: DateTime.now(),
                    date: selectedDate,
                    gender: selectedGender,
                    barangay: selectedBarangay,
                    motherAgeGroup: selectedMotherAgeGroup,
                    fatherAgeGroup: selectedFatherAgeGroup,
                    submittedBy: ''),
              );

              Navigator.pop(context, 'done');
            },
          ),
        ],
      ),
    );
    setState(() {});
  }

  void showNatalityContentDialog(BuildContext context,
      {required (String, Natality) natalityWithDocId,
      required User? user,
      required void Function(String documentId) deleteCallback}) async {
    final docId = natalityWithDocId.$1;
    final natality = natalityWithDocId.$2;
    final userId = user!.userId;

    final hasPermission = hasDeletePermission(
        docUserId: natality.userId, currentUserId: userId, role: user.role);

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Natality'),
            Text(
              timestampFormat.format(natality.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: "Birthdate",
                child: TextBox(
                  placeholder: dateFormat.format(natality.date),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Gender",
                child: TextBox(
                  placeholder: LocalData.findGenderKey(natality.gender),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Barangay",
                child: TextBox(
                  placeholder: natality.barangay.toUpperCase(),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Parents age",
                child: TextBox(
                  placeholder:
                      '${LocalData.findParentsAgeGroupKey(natality.motherAgeGroup)} & ${LocalData.findParentsAgeGroupKey(natality.fatherAgeGroup)}',
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Submitted by",
                child: TextBox(
                  placeholder: natality.submittedBy.toUpperCase(),
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
            child: Text('Delete',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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

  final List<(String, Natality)> data;

  final void Function((String, Natality) natality) callback;

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
              label: Text('Birthdate'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('Gender'),
            ),
            DataColumn2(
              label: Text('Barangay'),
            ),
            DataColumn2(
              label: Text('Parents age'),
            ),
            DataColumn2(
              label: Text('Submitted by'),
              numeric: true,
            ),
          ],
          source: NatalityDataSource(data: data, callback: callback)),
    );
  }
}

class NatalityDataSource extends material.DataTableSource {
  final List<(String, Natality)> data;
  final void Function((String, Natality) natality) callback;

  NatalityDataSource({required this.data, required this.callback});

  @override
  material.DataRow? getRow(int index) {
    if (index > data.length || index < 0) return null;
    final natalityWithDocId = data[index];
    final natality = natalityWithDocId.$2;
    return DataRow2(
        onTap: () {
          callback(natalityWithDocId);
        },
        cells: [
          material.DataCell(Text(
            timestampFormat.format(natality.timestamp),
            style: const TextStyle(fontSize: 12),
          )),
          material.DataCell(Text(dateFormat.format(natality.date))),
          material.DataCell(Text(natality.gender)),
          material.DataCell(Text(natality.barangay.toUpperCase())),
          material.DataCell(Text(
              '${LocalData.findParentsAgeGroupKey(natality.motherAgeGroup)} & ${LocalData.findParentsAgeGroupKey(natality.fatherAgeGroup)}')),
          material.DataCell(Text(natality.submittedBy.toUpperCase())),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
